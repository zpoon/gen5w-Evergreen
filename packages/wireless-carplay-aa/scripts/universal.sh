#!/system/bin/sh
# Universal build: the full build for a car that has no patch set of its own, when
# its projection apps run code we already have patches for.
#
# An .odex is the app's (optimised) dex plus a header with checksums of the
# framework it was made against. Cars with the same app code have the same dex
# inside different .odex files, so patches/universal/manifest keys each patch to
# the md5 of that dex (`lpatch odexdex`), not to the .odex file:
#   <part> app <App> <md5 of the dex in the stock .odex> <patch> <md5 of the result dex>
#   <part> file <library> <md5 of the stock library> <patch> <md5 of the result>
# A car gets the full build only if every app and file named there matches one of
# its lines; anything else stays in basic mode, as before.
#
# On success this writes patches/auto/ (stock, manifest, product): this car's own
# stock and result checksums in the usual patch-set format, so the parts check
# and install exactly as for any other car. cars.sh maps the unit to "auto" only
# while patches/auto/product is its own product id.
# Sourced by scripts/build.sh (needs BUILD_DIR, LOG, log, lp_bin, lp_md5, stock_src).
UNI=patches/universal/manifest
AUTO=patches/auto

# uni_needed: each part/name (with its kind) the universal manifest covers, once
uni_needed() {
    local _p _k _n _c _x _w _seen=" "
    while read -r _p _k _n _c _x _w; do
        case "$_p" in ''|\#*) continue ;; esac
        case "$_seen" in *" $_p/$_n "*) continue ;; esac
        _seen="$_seen$_p/$_n "
        echo "$_p $_k $_n"
    done < "$UNI"
}

# uni_line <part> <name> <code md5>: the patch and result md5 for that code, if any
uni_line() {
    local _p _k _n _c _x _w
    while read -r _p _k _n _c _x _w; do
        [ "$_p" = "$1" ] && [ "$_n" = "$2" ] && [ "$_c" = "$3" ] && { echo "$_x $_w"; return 0; }
    done < "$UNI"
    return 1
}

# uni_build_app <part> <name> <patch> <result dex md5>: the app, into $BUILD_DIR/<part>/
uni_build_app() {
    local _code="$BUILD_DIR/$2.code.dex" _dex="$BUILD_DIR/classes.dex" _out="$BUILD_DIR/$1/$2.apk"
    mkdir -p "$BUILD_DIR/$1" || return 1
    rm -f "$_dex" "$_out" 2>/dev/null
    "$(lp_bin)" odexdex "$(stock_src "/system/app/$2.odex")" "$_code" >> "$LOG" 2>&1 || return 1
    if ! "$(lp_bin)" delta "patches/$3" "$_code" "$_dex" >> "$LOG" 2>&1; then
        rm -f "$_code"
        return 1
    fi
    rm -f "$_code"
    [ "$(lp_md5 "$_dex")" = "$4" ] || { rm -f "$_dex"; return 1; }
    if ! "$(lp_bin)" zipadd "$(stock_src "/system/app/$2.apk")" "$_dex" "$_out" >> "$LOG" 2>&1; then
        rm -f "$_dex"
        return 1
    fi
    rm -f "$_dex"
    log "built $1/$2.apk from the stock files (universal patch ${3#universal/})"
    return 0
}

# universal_build: 0 and patches/auto written if every app and file matched
universal_build() {
    local _part _kind _name _code _l _src _st=" " _prod
    [ -s "$UNI" ] || return 1
    _prod=$(getprop ro.build.product 2>/dev/null)
    rm -rf "$AUTO" 2>/dev/null
    mkdir -p "$BUILD_DIR" || return 1
    rm -f "$BUILD_DIR/auto.stock" "$BUILD_DIR/auto.manifest" 2>/dev/null
    for _l in $(uni_needed | while read -r _part _kind _name; do echo "$_part:$_kind:$_name"; done); do
        _part=${_l%%:*}; _l=${_l#*:}; _kind=${_l%%:*}; _name=${_l#*:}
        if [ "$_kind" = app ]; then
            _src=$(stock_src "/system/app/$_name.odex")
            if ! "$(lp_bin)" odexdex "$_src" "$BUILD_DIR/probe.dex" >/dev/null 2>&1; then
                log "universal build: $_src is missing or not an odex"
                rm -f "$BUILD_DIR/probe.dex"
                return 1
            fi
            _code=$(lp_md5 "$BUILD_DIR/probe.dex")
            rm -f "$BUILD_DIR/probe.dex"
        else
            _code=$(lp_md5 "$(stock_src "/system/lib/$_name")")
        fi
        _l=$(uni_line "$_part" "$_name" "$_code") || {
            log "universal build: no patch for $_name (code $_code)"
            return 1
        }
        set -- $_l
        if [ "$_kind" = app ]; then
            uni_build_app "$_part" "$_name" "$1" "$2" || { log "universal build: $_name did not rebuild"; return 1; }
            echo "$_part app $_name universal $(lp_md5 "$BUILD_DIR/$_part/$_name.apk")" >> "$BUILD_DIR/auto.manifest"
            case "$_st" in *" $_name "*) ;; *)
                _st="$_st$_name "
                echo "$_name.apk $(lp_md5 "$(stock_src "/system/app/$_name.apk")")" >> "$BUILD_DIR/auto.stock"
                echo "$_name.odex $(lp_md5 "$_src")" >> "$BUILD_DIR/auto.stock" ;;
            esac
        else
            build_one "$_part" file "$_name" "$1" "$2" || { log "universal build: $_name did not rebuild"; return 1; }
            echo "$_part file $_name universal $2" >> "$BUILD_DIR/auto.manifest"
            echo "$_name $_code" >> "$BUILD_DIR/auto.stock"
        fi
    done
    mkdir -p "$AUTO" || return 1
    mv "$BUILD_DIR/auto.stock" "$AUTO/stock" || return 1
    mv "$BUILD_DIR/auto.manifest" "$AUTO/manifest" || return 1
    echo "$_prod" > "$AUTO/product" || return 1
    log "universal build: every projection app matches code we have patches for"
    return 0
}

# universal_rebuilt: the files patches/auto lists are still in the build dir
universal_rebuilt() {
    local _p _k _n _x _w _f
    [ -s "$AUTO/manifest" ] || return 1
    while read -r _p _k _n _x _w; do
        [ -n "$_p" ] || continue
        if [ "$_k" = app ]; then _f="$BUILD_DIR/$_p/$_n.apk"; else _f="$BUILD_DIR/$_p/$_n"; fi
        [ -s "$_f" ] && [ "$(lp_md5 "$_f")" = "$_w" ] || return 1
    done < "$AUTO/manifest"
    return 0
}
