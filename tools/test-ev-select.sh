#!/bin/sh
# Off-car test of the EV build selection in packages/wireless-carplay-aa/scripts/build.sh:
# +ev manifest lines replace the plain line for the same part and file unless
# EVERGREEN-NO-EV is next to our NEMESIS.data on the install drive; a set with no
# +ev lines builds as before; a "code" line that doesn't fit falls back to the next
# line for the same file, and an EV line that doesn't fit drops EV altogether.
# build_one is stubbed (it records what would be built; a patch named *nofit* fails).
#   tools/test-ev-select.sh [shell]   (default sh; CI also runs mksh)
set -e
SH=${1:-sh}
ROOT=$(cd "$(dirname "$0")/.." && pwd)
T=$(mktemp -d); trap 'rm -rf "$T"' EXIT
fail=0
check() { if [ "$2" = "$3" ]; then echo "ok    $1"; else echo "FAIL  $1: wanted [$2], got [$3]"; fail=1; fi; }

mkdir -p "$T/pkg/scripts" "$T/pkg/patches/car" "$T/drive"
# the drive paths rewritten into the sandbox, as tools/mock/install-test.sh does
sed -e "s|/storage/usb0|$T/drive|g" -e "s|/storage/usb[12]|$T/none|g" -e "s|/mnt/media_rw/usb[0-9]|$T/none|g" \
    "$ROOT/packages/wireless-carplay-aa/scripts/build.sh" > "$T/pkg/scripts/build.sh"
: > "$T/pkg/scripts/lpatch.sh"; : > "$T/pkg/scripts/cars.sh"; : > "$T/pkg/scripts/universal.sh"
cat > "$T/pkg/run.sh" <<'R'
log() { echo "log: $1" >> "$T/log"; }
car_variant() { echo car; }
. ./scripts/build.sh
BUILD_DIR=$T/build
build_one() { case "$4" in *nofit*) echo "$1 $3 $4 (no fit)" >> "$T/built"; return 1 ;; esac; echo "$1 $3 $4" >> "$T/built"; }
build_optional() { :; }
build_payloads
R
run() { rm -rf "$T/built" "$T/log" "$T/build"; ( cd "$T/pkg" && T=$T "$SH" run.sh ); }
built() { tr '\n' '|' < "$T/built"; }

cat > "$T/pkg/patches/car/manifest" <<'M'
2_tbt app HKMC_GPM car/HKMC_GPM.tbt.lpd aaa
2_tbt app HKMC_DiPO car/HKMC_DiPO.tbt.lpd bbb
3_bridge app HKMC_DiPO car/HKMC_DiPO.bridge.lpd ccc
2_tbt file libautoreceiver_infobank.so common/lib.tbt.lpd ddd
2_tbt+ev app HKMC_GPM car/HKMC_GPM.ev.lpd eee
2_tbt+ev file libautoreceiver_infobank.so common/lib.ev.lpd fff
M
run
check "EV by default: the +ev builds replace the plain GPM and library" \
    "2_tbt HKMC_GPM car/HKMC_GPM.ev.lpd|2_tbt libautoreceiver_infobank.so common/lib.ev.lpd|2_tbt HKMC_DiPO car/HKMC_DiPO.tbt.lpd|3_bridge HKMC_DiPO car/HKMC_DiPO.bridge.lpd|" "$(built)"
check "EV choice recorded" "1" "$(cat "$T/build/ev")"

: > "$T/drive/EVERGREEN-NO-EV"
printf '[nemesis]\ntype=install\npath=packages/wireless.carplay.aa.zip\n' > "$T/drive/NEMESIS.data"
run
check "EVERGREEN-NO-EV: plain builds only" \
    "2_tbt HKMC_GPM car/HKMC_GPM.tbt.lpd|2_tbt HKMC_DiPO car/HKMC_DiPO.tbt.lpd|3_bridge HKMC_DiPO car/HKMC_DiPO.bridge.lpd|2_tbt libautoreceiver_infobank.so common/lib.tbt.lpd|" "$(built)"
check "plain choice recorded" "0" "$(cat "$T/build/ev")"
grep -q "EVERGREEN-NO-EV on the install drive" "$T/log" && echo "ok    the opt-out is logged" || { echo "FAIL  the opt-out isn't logged"; fail=1; }

printf '[nemesis]\ntype=install\npath=packages/other.package.zip\n' > "$T/drive/NEMESIS.data"
run
check "EVERGREEN-NO-EV for another package's drive is ignored" "1" "$(cat "$T/build/ev")"

rm -f "$T/drive/EVERGREEN-NO-EV"
grep -v '+ev' "$T/pkg/patches/car/manifest" > "$T/m" && mv "$T/m" "$T/pkg/patches/car/manifest"
run
check "a set without +ev lines builds as before" \
    "2_tbt HKMC_GPM car/HKMC_GPM.tbt.lpd|2_tbt HKMC_DiPO car/HKMC_DiPO.tbt.lpd|3_bridge HKMC_DiPO car/HKMC_DiPO.bridge.lpd|2_tbt libautoreceiver_infobank.so common/lib.tbt.lpd|" "$(built)"
check "no EV recorded" "0" "$(cat "$T/build/ev")"

# code lines (built from the code in the car's own .odex), each followed by a plain line
cat > "$T/pkg/patches/car/manifest" <<'M'
2_tbt code HKMC_GPM universal/HKMC_GPM.tbt.code.lpd aaa
2_tbt app HKMC_GPM car/HKMC_GPM.tbt.lpd aaa
2_tbt app HKMC_DiPO car/HKMC_DiPO.tbt.lpd bbb
2_tbt file libautoreceiver_infobank.so common/lib.tbt.lpd ddd
2_tbt+ev code HKMC_GPM universal/HKMC_GPM.ev.code.lpd eee
2_tbt+ev file libautoreceiver_infobank.so common/lib.ev.lpd fff
M
run
check "code lines that fit: EV GPM from the car's code" \
    "2_tbt HKMC_GPM universal/HKMC_GPM.ev.code.lpd|2_tbt libautoreceiver_infobank.so common/lib.ev.lpd|2_tbt HKMC_DiPO car/HKMC_DiPO.tbt.lpd|" "$(built)"
check "EV recorded" "1" "$(cat "$T/build/ev")"

sed -i 's#HKMC_GPM.ev.code.lpd#HKMC_GPM.ev.nofit.lpd#' "$T/pkg/patches/car/manifest"
run
check "the EV code line doesn't fit: no EV at all, plain GPM from the code line" \
    "2_tbt HKMC_GPM universal/HKMC_GPM.ev.nofit.lpd (no fit)|2_tbt libautoreceiver_infobank.so common/lib.ev.lpd|2_tbt HKMC_GPM universal/HKMC_GPM.tbt.code.lpd|2_tbt HKMC_DiPO car/HKMC_DiPO.tbt.lpd|2_tbt libautoreceiver_infobank.so common/lib.tbt.lpd|" "$(built)"
check "plain recorded after the EV fallback" "0" "$(cat "$T/build/ev")"
grep -q "doesn't fit this car's files: building without the EV features" "$T/log" && echo "ok    the EV fallback is logged" || { echo "FAIL  the EV fallback isn't logged"; fail=1; }

sed -i 's#HKMC_GPM.tbt.code.lpd#HKMC_GPM.tbt.nofit.lpd#' "$T/pkg/patches/car/manifest"
run
check "neither code line fits: the set's own GPM patch" \
    "2_tbt HKMC_GPM universal/HKMC_GPM.ev.nofit.lpd (no fit)|2_tbt libautoreceiver_infobank.so common/lib.ev.lpd|2_tbt HKMC_GPM universal/HKMC_GPM.tbt.nofit.lpd (no fit)|2_tbt HKMC_GPM car/HKMC_GPM.tbt.lpd|2_tbt HKMC_DiPO car/HKMC_DiPO.tbt.lpd|2_tbt libautoreceiver_infobank.so common/lib.tbt.lpd|" "$(built)"

sed -i 's#car/HKMC_DiPO.tbt.lpd#car/HKMC_DiPO.tbt.nofit.lpd#' "$T/pkg/patches/car/manifest"
if run 2>/dev/null; then echo "FAIL  a plain line that doesn't fit should stop the build"; fail=1; else echo "ok    a plain line that doesn't fit stops the build"; fi
[ $fail = 0 ]
