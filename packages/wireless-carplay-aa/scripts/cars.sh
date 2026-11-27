#!/system/bin/sh
# Car lookup from the package's patch data. Set CARS_DIR to the package's
# patches/ folder before sourcing.
#   patches/cars             <product prefix> <variant> <car name>
#   patches/<variant>/stock  <file name> <md5 of the stock file>
#   patches/<variant>/manifest  <part> <app|file> <name> <patch> <md5 of the result>

car_line() {
    local _p _pre _v _n
    _p=$(getprop ro.build.product 2>/dev/null)
    [ -n "$_p" ] && [ -s "$CARS_DIR/cars" ] || return 1
    while read -r _pre _v _n; do
        case "$_pre" in ''|\#*) continue ;; esac
        case "$_p" in "$_pre"*) echo "$_v $_n"; return 0 ;; esac
    done < "$CARS_DIR/cars"
    # no patch set of its own, but the universal build matched this unit at install
    # (scripts/universal.sh wrote patches/auto for exactly this product id)
    if [ -s "$CARS_DIR/auto/manifest" ] && [ "$(cat "$CARS_DIR/auto/product" 2>/dev/null)" = "$_p" ]; then
        echo "auto Gen5W unit, universal build (${_p%%.*})"
        return 0
    fi
    return 1
}
car_variant() { local _l; _l=$(car_line) || return 1; echo "${_l%% *}"; }
car_name() { local _l; _l=$(car_line) || return 1; echo "${_l#* }"; }

# stock_sum <file name>: md5 of that stock file on this car
stock_sum() {
    local _f _s
    [ -s "$CARS_DIR/$VARIANT/stock" ] || return 1
    while read -r _f _s; do
        [ "$_f" = "$1" ] && { echo "$_s"; return 0; }
    done < "$CARS_DIR/$VARIANT/stock"
    return 1
}

# built_sum <part> <name>: md5 of the file scripts/build.sh builds for that part
# A "code" line's md5 is of the dex it builds, not of the APK (that depends on the car's own
# stock APK): there, the APK scripts/build.sh built for the part is the answer.
built_sum() {
    local _p _k _n _x _s _f _l
    [ -s "$CARS_DIR/$VARIANT/manifest" ] || return 1
    while read -r _p _k _n _x _s; do
        [ "$_p" = "$1" ] && [ "$_n" = "$2" ] || continue
        if [ "$_k" = code ]; then
            _f=/data/nemesis/build/wireless.carplay.aa/$1/$2.apk
            [ -s "$_f" ] || return 1
            _l=$(md5 "$_f" 2>/dev/null) || return 1
            set -- $_l
            echo "$1"
            return 0
        fi
        echo "$_s"
        return 0
    done < "$CARS_DIR/$VARIANT/manifest"
    return 1
}
