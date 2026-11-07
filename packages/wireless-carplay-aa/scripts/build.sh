#!/system/bin/sh
# Rebuild the modified projection apps on the head unit from its own stock files.
# The package carries only patch files (patches/<car>/*.lpd). For each app,
# `lpatch delta` rebuilds the modified code from the stock .odex - only if that
# .odex is the exact expected original - and `lpatch zipadd` adds it to the stock
# APK. Every result must match the md5 in patches/<car>/manifest.
# Output goes to $BUILD_DIR/<part>/, where the parts pick it up.
#
# EV features: a manifest line whose part ends in "+ev" (e.g. "2_tbt+ev app
# HKMC_GPM neev/HKMC_GPM.ev.lpd <md5>") is the EV build of that file (turn-by-turn
# plus egmp-aa-ev-feat's EV routing, preconditioning and logging). It replaces the
# plain line for the same part and file, unless an empty EVERGREEN-NO-EV file sits
# next to our NEMESIS.data on the install drive. A car with no +ev lines builds as
# before. $BUILD_DIR/ev records which way it went (1 or 0) for the install log.
BUILD_DIR=/data/nemesis/build/wireless.carplay.aa
TBT_BACKUP=/data/nemesis/backup/projection.tbt
MENU_BACKUP=/data/nemesis/backup/projection.menu
LP_ROOT=.
. ./scripts/lpatch.sh

CARS_DIR=patches
. ./scripts/cars.sh
. ./scripts/universal.sh

lp_md5() {
    local _l
    _l=$("$(lp_bin)" md5 "$1" 2>/dev/null) || return 1
    set -- $_l
    echo "$1"
}

# the stock copy of a system file: a part's snapshot when it exists (the live
# file may already be modified), otherwise the live file
stock_src() {
    local _b
    for _b in "$TBT_BACKUP/${1##*/}" "$MENU_BACKUP/${1##*/}"; do
        [ -s "$_b" ] && { echo "$_b"; return; }
    done
    echo "$1"
}

# build_one <part> <kind> <name> <patch> <md5> [optional]: rebuild one file into
# $BUILD_DIR/<part>/ (an optional one logs a mismatch as a skip, not a failure)
build_one() {
    local _part="$1" _kind="$2" _name="$3" _patch="$4" _want="$5" _out _src _odex _tmp _f="FAIL:"
    [ "$6" = optional ] && _f="skip (optional):"
    _tmp="$BUILD_DIR/classes.dex"
    mkdir -p "$BUILD_DIR/$_part" || return 1
    case "$_kind" in
        app) _out="$BUILD_DIR/$_part/$_name.apk" ;;
        file) _out="$BUILD_DIR/$_part/$_name" ;;
        *) log "FAIL: bad manifest line ($_part $_kind)"; return 1 ;;
    esac
    if [ -s "$_out" ] && [ "$(lp_md5 "$_out")" = "$_want" ]; then
        return 0
    fi
    rm -f "$_out" "$_tmp" 2>/dev/null
    if [ "$_kind" = app ]; then
        _src=$(stock_src "/system/app/$_name.apk")
        _odex=$(stock_src "/system/app/$_name.odex")
        if ! "$(lp_bin)" delta "patches/$_patch" "$_odex" "$_tmp" >> "$LOG" 2>&1; then
            log "$_f $_odex is not the stock file this patch needs"
            return 1
        fi
        if ! "$(lp_bin)" zipadd "$_src" "$_tmp" "$_out" >> "$LOG" 2>&1; then
            rm -f "$_tmp"
            log "$_f could not assemble $_name.apk"
            return 1
        fi
        rm -f "$_tmp"
    else
        _src=$(stock_src "/system/lib/$_name")
        if ! "$(lp_bin)" delta "patches/$_patch" "$_src" "$_out" >> "$LOG" 2>&1; then
            log "$_f $_src is not the stock file this patch needs"
            return 1
        fi
    fi
    if [ "$(lp_md5 "$_out")" != "$_want" ]; then
        rm -f "$_out"
        log "$_f rebuilt $_name does not match the expected result"
        return 1
    fi
    log "built $_part/${_out##*/} from the stock files"
    return 0
}

# EV builds wanted? Yes unless EVERGREEN-NO-EV is on the install drive.
ev_wanted() {
    local _d
    for _d in /storage/usb0 /storage/usb1 /storage/usb2 /mnt/media_rw/usb0 /mnt/media_rw/usb1 /mnt/media_rw/usb2; do
        [ -f "$_d/EVERGREEN-NO-EV" ] || continue
        grep -q 'wireless\.carplay\.aa\.zip' "$_d/NEMESIS.data" 2>/dev/null && return 1
    done
    return 0
}

# has_ev_line <manifest> <part> <name>: the manifest has an EV build of that file
has_ev_line() {
    local _p _k _n _x _s
    while read -r _p _k _n _x _s; do
        [ "$_p" = "$2+ev" ] && [ "$_n" = "$3" ] && return 0
    done < "$1"
    return 1
}

build_payloads() {
    local _v _m _part _kind _name _patch _want _ev=0 _evn=0
    _v=$(car_variant) || { log "FAIL: no patch set for this car"; return 1; }
    if [ "$_v" = auto ]; then   # the universal build (scripts/universal.sh)
        universal_rebuilt || universal_build || return 1
        build_optional
        return 0
    fi
    _m="patches/$_v/manifest"
    if [ ! -s "$_m" ]; then
        log "FAIL: missing $_m"
        return 1
    fi
    mkdir -p "$BUILD_DIR/2_tbt" "$BUILD_DIR/3_bridge" || return 1
    if grep -q '^[^ ]*+ev ' "$_m"; then
        if ev_wanted; then
            _ev=1
        else
            log "EVERGREEN-NO-EV on the install drive: turn-by-turn build without the EV features"
        fi
    fi
    while read -r _part _kind _name _patch _want; do
        [ -n "$_part" ] || continue
        case "$_part" in
            *+ev)
                [ $_ev = 1 ] || continue
                _part=${_part%+ev}
                _evn=$((_evn + 1))
                ;;
            *)
                [ $_ev = 1 ] && has_ev_line "$_m" "$_part" "$_name" && continue
                ;;
        esac
        build_one "$_part" "$_kind" "$_name" "$_patch" "$_want" || return 1
    done < "$_m"
    echo $_ev > "$BUILD_DIR/ev"
    # a set without a library line (the car's Android Auto library has no patch yet):
    # part 2 leaves the library stock, so only Android Auto turn-by-turn on the cluster is missing
    rm -f "$BUILD_DIR/2_tbt/no-lib" 2>/dev/null
    if ! grep -q '^2_tbt[^ ]* file libautoreceiver_infobank.so ' "$_m"; then
        : > "$BUILD_DIR/2_tbt/no-lib" || return 1
        log "no Android Auto library patch for this car yet: the library stays stock (Android Auto turn-by-turn on the cluster isn't in this build)"
    fi
    [ $_ev = 1 ] && log "EV features: $_evn file(s) built with EV routing, preconditioning and logging"
    build_optional
    return 0
}

clean_build() {
    case "$BUILD_DIR" in
        /data/nemesis/build/wireless.carplay.aa) rm -rf "$BUILD_DIR"; rmdir /data/nemesis/build 2>/dev/null ;;
    esac
}

# build_optional: the fixes in patches/common/optional, for units whose stock file
# matches. A file can have one line per stock version: the first that fits is built
# and the rest are passed over. Anything that fits no line is skipped, and its part
# has nothing to install.
build_optional() {
    local _part _kind _name _patch _want _done=" "
    [ -s patches/common/optional ] || return 0
    while read -r _part _kind _name _patch _want; do
        case "$_part" in ''|\#*) continue ;; esac
        case "$_done" in *" $_part/$_name "*) continue ;; esac
        if build_one "$_part" "$_kind" "$_name" "$_patch" "$_want" optional; then
            _done="$_done$_part/$_name "
        else
            rm -f "$BUILD_DIR/$_part/$_name.apk" "$BUILD_DIR/$_part/$_name" 2>/dev/null
        fi
    done < patches/common/optional
    return 0
}
