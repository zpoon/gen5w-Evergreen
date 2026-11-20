#!/bin/sh
# The product ids patches/cars maps to each patch set, read through the package's own lookup
# (packages/wireless-carplay-aa/scripts/cars.sh), and the descriptor's os= taking each of them.
#   tools/test-cars.sh [shell]   (default sh; CI also runs mksh)
set -e
SH=$(command -v "${1:-sh}") || { echo "no shell: ${1:-sh}"; exit 1; }
ROOT=$(cd "$(dirname "$0")/.." && pwd)
fail=0
check() { if [ "$2" = "$3" ]; then echo "ok    $1"; else echo "FAIL  $1: wanted [$2], got [$3]"; fail=1; fi; }
# shellcheck disable=SC2016 # expanded by the shell under test
set_for() {
    PRODUCT=$1 CARS_DIR=$ROOT/patches "$SH" -c '. "$0"; getprop() { echo "$PRODUCT"; }; car_variant || echo none' \
        "$ROOT/packages/wireless-carplay-aa/scripts/cars.sh"
}
os=$(sed -n 's/^os="\(.*\)"$/\1/p' "$ROOT/packages/wireless-carplay-aa/NEMESIS.data")
while read -r id want why; do
    case $id in ''|\#*) continue ;; esac
    check "$id -> $want ($why)" "$want" "$(set_for "$id")"
    hit=no
    for item in $(echo "$os" | tr ',' ' '); do
        # shellcheck disable=SC2254 # the os= item is a glob
        case $id in $item) hit=yes ;; esac
    done
    check "os= takes $id" yes "$hit"
done << 'IDS'
CVEV.USA.0000.V015.012.260507 ev6 EV6 US
CVEV.CAN.0000.V015.011.260206 ev6_ca EV6 Canada
NEEV.USA.0000.V015.012.260507 neev Ioniq 5 US 260507
NEEV.USA.0000.V016.010.260903 neev23_260903 Ioniq 5 2022 US 260903
NEEV23.USA.S5W_M.V016.010.260903 neev23_260903 Ioniq 5 2023 US 260903, S5W_M
NEEV23SE.USA.0000.V016.010.260903 neev23_260903 Ioniq 5 2024 SE US 260903
NEEV.CAN.0000.V015.011.260206 neev_ca Ioniq 5 Canada 260206
NEEV.CAN.0000.V016.010.260903 neev23_260903 Ioniq 5 Canada 260903, the US 260903 stock files
NEEV.CAN.S5W_M.V016.010.260903 neev23_260903 Ioniq 5 Canada 260903, S5W_M
NQ5HEV.USA.0000.V015.012.260507 nq5 Sportage Hybrid
LX2PE.USA.0000.V016.010.260903 lx2pe Palisade
CEEV.USA.0000.V016.010.260903 ceev Ioniq 6 US 260903
IDS
check "another car isn't mapped" none "$(set_for OTHER.USA.0000.V016.010.260903)"
check "os= under NEMESIS's 255 characters" yes "$([ "${#os}" -le 255 ] && echo yes || echo "no (${#os})")"
[ "$fail" = 0 ] && echo "cars: PASS" || { echo "cars: FAIL"; exit 1; }
