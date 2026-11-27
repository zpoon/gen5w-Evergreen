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
# before. $BUILD_DIR/ev records whether any EV build went in (1 or 0) for the install log.
# The EV features fall back on their own, so one that doesn't fit this car's files never
# takes out the other or drops the car to basic mode:
# - the EV builds of files that also have a plain line (GPM and the Android Auto library:
#   the Android Auto EV features) go in all together or not at all; if one can't be built,
#   those files get their plain build;
# - a file with only a +ev line (libiap2session.so, for CarPlay EV routing: the plain
#   build leaves it stock) is built if it fits, and otherwise stays stock.
# Only a plain line that doesn't fit stops the build, as before.
#
# Code lines: "<part> code <App> <patch> <md5 of the result dex>" build an app from
# the dex inside the car's own stock .odex (`lpatch odexdex`, as the universal build
# does), so a set can use a patch made from another car with the same app code
# without that car's stock APK here. The patch's own header checks the code; the
# part's stock check still pins the exact .odex and APK. A code line that doesn't
# fit is not an error: the next line for the same part and app is tried instead,
# so a code line must always be followed by a plain line for the same file.
BUILD_DIR=/data/nemesis/build/wireless.carplay.aa
TBT_BACKUP=/data/nemesis/backup/projection.tbt
MENU_BACKUP=/data/nemesis/backup/projection.menu
# shellcheck disable=SC2034 # scripts/lpatch.sh reads it
LP_ROOT=.
. ./scripts/lpatch.sh

# shellcheck disable=SC2034 # scripts/cars.sh reads it
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
    local _part="$1" _kind="$2" _name="$3" _patch="$4" _want="$5" _out _src _odex _tmp _code _f="FAIL:"
    [ "$6" = optional ] && _f="skip (optional):"
    [ "$_kind" = code ] && _f="not used (the next line for $_name is tried):"
    _tmp="$BUILD_DIR/classes.dex"
    mkdir -p "$BUILD_DIR/$_part" || return 1
    case "$_kind" in
        app|code) _out="$BUILD_DIR/$_part/$_name.apk" ;;
        file) _out="$BUILD_DIR/$_part/$_name" ;;
        *) log "FAIL: bad manifest line ($_part $_kind)"; return 1 ;;
    esac
    if [ "$_kind" != code ] && [ -s "$_out" ] && [ "$(lp_md5 "$_out")" = "$_want" ]; then
        return 0
    fi
    rm -f "$_out" "$_tmp" 2>/dev/null
    if [ "$_kind" = code ]; then
        _src=$(stock_src "/system/app/$_name.apk")
        _odex=$(stock_src "/system/app/$_name.odex")
        _code="$BUILD_DIR/$_name.code.dex"
        if ! "$(lp_bin)" odexdex "$_odex" "$_code" >> "$LOG" 2>&1; then
            rm -f "$_code"
            log "$_f $_odex is missing or not an odex"
            return 1
        fi
        if ! "$(lp_bin)" delta "patches/$_patch" "$_code" "$_tmp" >> "$LOG" 2>&1; then
            rm -f "$_code" "$_tmp"
            log "$_f the code in $_odex is not the code ${_patch##*/} needs"
            return 1
        fi
        rm -f "$_code"
        if [ "$(lp_md5 "$_tmp")" != "$_want" ]; then
            rm -f "$_tmp"
            log "$_f rebuilt $_name code does not match the expected result"
            return 1
        fi
        if ! "$(lp_bin)" zipadd "$_src" "$_tmp" "$_out" >> "$LOG" 2>&1; then
            rm -f "$_tmp" "$_out"
            log "$_f could not assemble $_name.apk"
            return 1
        fi
        rm -f "$_tmp"
        log "built $_part/${_out##*/} from the code in the stock .odex (${_patch##*/})"
        return 0
    fi
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

# plain_line <manifest> <part> <name>: the manifest has a plain (not +ev) line for that file
plain_line() {
    local _p _k _n _x _s
    while read -r _p _k _n _x _s; do
        [ "$_p" = "$2" ] && [ "$_n" = "$3" ] && return 0
    done < "$1"
    return 1
}

# ev_complete <manifest> <done list>: every file with both a +ev line and a plain line
# got an EV build
ev_complete() {
    local _p _k _n _x _s
    while read -r _p _k _n _x _s; do
        case "$_p" in *+ev) ;; *) continue ;; esac
        plain_line "$1" "${_p%+ev}" "$_n" || continue
        case "$2" in *" ${_p%+ev}/$_n "*) ;; *) return 1 ;; esac
    done < "$1"
    return 0
}

build_payloads() {
    local _v _m _part _kind _name _patch _want _l _ev=0 _evn=0 _done=" " _keep _evl
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
    # the EV lines first: one that doesn't fit is left out (see the top), never an error
    if [ $_ev = 1 ]; then
        while read -r _part _kind _name _patch _want; do
            case "$_part" in *+ev) ;; *) continue ;; esac
            _part=${_part%+ev}
            case "$_done" in *" $_part/$_name "*) continue ;; esac
            if build_one "$_part" "$_kind" "$_name" "$_patch" "$_want" optional; then
                _done="$_done$_part/$_name "
                _evn=$((_evn + 1))
            elif ! plain_line "$_m" "$_part" "$_name"; then
                log "EV build without $_part/$_name: it doesn't fit this car's files, so the stock $_name stays"
            fi
        done < "$_m"
        if ! ev_complete "$_m" "$_done"; then
            log "the EV build doesn't fit this car's files: building without the EV features for the files that have a plain build"
            _keep=" "
            for _l in $_done; do
                if plain_line "$_m" "${_l%%/*}" "${_l#*/}"; then
                    rm -f "$BUILD_DIR/$_l.apk" "$BUILD_DIR/$_l" 2>/dev/null
                    _evn=$((_evn - 1))
                else
                    _keep="$_keep$_l "
                fi
            done
            _done=$_keep
        fi
        [ $_evn -gt 0 ] || _ev=0
    fi
    _evl=$_done
    # then the plain lines, for each file the first one that fits
    while read -r _part _kind _name _patch _want; do
        [ -n "$_part" ] || continue
        case "$_part" in *+ev) continue ;; esac
        case "$_done" in *" $_part/$_name "*) continue ;; esac
        if build_one "$_part" "$_kind" "$_name" "$_patch" "$_want"; then
            _done="$_done$_part/$_name "
        elif [ "$_kind" != code ]; then
            return 1
        fi
    done < "$_m"
    echo $_ev > "$BUILD_DIR/ev"
    # a set without a library line (the car's Android Auto library has no patch yet):
    # part 2 leaves the library stock, so only Android Auto turn-by-turn on the cluster is missing
    rm -f "$BUILD_DIR/2_tbt/no-lib" 2>/dev/null
    if ! grep -q '^2_tbt[^ ]* file libautoreceiver_infobank.so ' "$_m"; then
        : > "$BUILD_DIR/2_tbt/no-lib" || return 1
        log "no Android Auto library patch for this car yet: the library stays stock (Android Auto turn-by-turn on the cluster isn't in this build)"
    fi
    [ $_ev = 1 ] && log "EV features: $_evn file(s) built with them:${_evl% }"
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
