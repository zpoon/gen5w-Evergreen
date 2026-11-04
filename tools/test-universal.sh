#!/bin/sh
# Off-car test of the universal build (packages/wireless-carplay-aa/scripts/universal.sh)
# with made-up apps: no stock files needed. Each "app" is a stock APK plus an odex
# whose code (the dex inside) is what universal patches are keyed to.
#   tools/test-universal.sh [shell]   (default sh; CI also runs mksh)
# Needs cc (builds the host lpatch) and python3 with tools/requirements.txt.
set -e
SH=${1:-sh}
ROOT=$(cd "$(dirname "$0")/.." && pwd)
T=$(mktemp -d); trap 'rm -rf "$T"' EXIT
fail=0
check() { if [ "$2" = "$3" ]; then echo "ok    $1"; else echo "FAIL  $1: wanted [$2], got [$3]"; fail=1; fi; }
cc -DHOST -O2 -o "$T/lpatch-host" "$ROOT/tools/lpatch/lpatch.c"

P=$T/pkg; S=$T/root
mkdir -p "$P/scripts" "$P/patches/universal" "$P/patches/common" "$S/system/app" "$S/system/lib" "$S/data"
# the package's scripts, with the unit's paths moved into the sandbox
for f in build.sh cars.sh universal.sh; do
    sed -e "s|/system/|$S/system/|g" -e "s|/data/nemesis/|$S/data/|g" "$ROOT/packages/wireless-carplay-aa/scripts/$f" > "$P/scripts/$f"
done
echo "lp_bin() { echo $T/lpatch-host; }" > "$P/scripts/lpatch.sh"
echo "NOPE.USA. nope Some other car" > "$P/patches/cars"

# two apps and a library; "new" is the car under test, "ref" the car the patches were made from
python3 - "$T" <<'EOF'
import os, random, struct, sys, zipfile
t = sys.argv[1]; r = random.Random(7)
def odex(code, deps):
    return b'dey\n036\0' + struct.pack('<8I', 40, len(code), 40 + len(code), len(deps), 0, 0, 0, 0) + code + deps
os.makedirs(t + '/gen', exist_ok=True)
for app in ('AppA', 'AppB'):
    code = b'dex\n035\0' + r.randbytes(20000)
    open('%s/gen/%s.code' % (t, app), 'wb').write(code)
    open('%s/gen/%s.built' % (t, app), 'wb').write(b'dex\n035\0' + code[8:12000] + r.randbytes(500) + code[12000:])
    open('%s/gen/%s.ref.odex' % (t, app), 'wb').write(odex(code, b'REF' + r.randbytes(200)))
    open('%s/root/system/app/%s.odex' % (t, app), 'wb').write(odex(code, b'NEW' + r.randbytes(200)))   # same code, other deps
    with zipfile.ZipFile('%s/root/system/app/%s.apk' % (t, app), 'w') as z:
        z.writestr('AndroidManifest.xml', r.randbytes(3000))
lib = r.randbytes(30000)
open(t + '/root/system/lib/libtest.so', 'wb').write(lib)
open(t + '/gen/libtest.built', 'wb').write(lib[:100] + b'patched' + lib[107:])
EOF
md5() { md5sum "$1" | cut -d' ' -f1; }
mf=$P/patches/universal/manifest; : > "$mf"
for a in AppA AppB; do
    c=$(md5 "$T/gen/$a.code")
    python3 "$ROOT/tools/mkdelta.py" "$T/gen/$a.code" "$T/gen/$a.built" "$P/patches/universal/$a.tbt.lpd" > /dev/null
    echo "2_tbt app $a $c universal/$a.tbt.lpd $(md5 "$T/gen/$a.built")" >> "$mf"
done
python3 "$ROOT/tools/mkdelta.py" "$S/system/lib/libtest.so" "$T/gen/libtest.built" "$P/patches/common/libtest.lpd" > /dev/null
echo "2_tbt file libtest.so $(md5 "$S/system/lib/libtest.so") common/libtest.lpd $(md5 "$T/gen/libtest.built")" >> "$mf"
cp -r "$P/patches" "$T/patches.orig"

# run_build <product>: universal_build in the package dir; prints its exit code
cat > "$P/run.sh" <<'R'
log() { echo "log: $1" >> "$T/log"; }
getprop() { echo "$PRODUCT"; }
. ./scripts/build.sh
BUILD_DIR=$T/build
universal_build; echo "rc=$?"
CARS_DIR=patches
car_line || echo "no car"
R
run_build() { rm -rf "$T/build" "$T/log" "$P/patches/auto"; (cd "$P" && T=$T PRODUCT=$1 LOG=$T/lpatch.log "$SH" run.sh); }

out=$(run_build XQ9.USA.0000.V015.012.260507)
check "matching code: universal build succeeds" "rc=0" "$(echo "$out" | head -1)"
check "the unit is mapped to the generated set" "auto Gen5W unit, universal build (XQ9)" "$(echo "$out" | sed -n 2p)"
check "built AppA is the patched app" "$(md5 "$T/gen/AppA.built")" "$(unzip -p "$T/build/2_tbt/AppA.apk" classes.dex | md5sum | cut -d' ' -f1)"
check "built library is the patched one" "$(md5 "$T/gen/libtest.built")" "$(md5 "$T/build/2_tbt/libtest.so")"
check "generated stock list has the car's own files" \
    "AppA.apk $(md5 "$S/system/app/AppA.apk")|AppA.odex $(md5 "$S/system/app/AppA.odex")|AppB.apk $(md5 "$S/system/app/AppB.apk")|AppB.odex $(md5 "$S/system/app/AppB.odex")|libtest.so $(md5 "$S/system/lib/libtest.so")|" \
    "$(tr '\n' '|' < "$P/patches/auto/stock")"
check "generated manifest lists the built files" "2_tbt app AppA universal $(md5 "$T/build/2_tbt/AppA.apk")" "$(head -1 "$P/patches/auto/manifest")"
check "another product id isn't mapped to it" "no car" "$( (cd "$P" && T=$T PRODUCT=OTHER.USA.1 sh -c '. ./scripts/cars.sh; CARS_DIR=patches; getprop() { echo OTHER.USA.1; }; car_line || echo "no car"') )"

# different code in one app: no full build, nothing left behind
cp "$S/system/app/AppB.odex" "$T/AppB.keep"
python3 -c "import sys; p=sys.argv[1]; b=bytearray(open(p,'rb').read()); b[5000]^=1; open(p,'wb').write(b)" "$S/system/app/AppB.odex"
out=$(run_build XQ9.USA.0000.V015.012.260507)
check "one app with other code: no universal build" "rc=1" "$(echo "$out" | head -1)"
check "nothing generated" "no" "$([ -e "$P/patches/auto" ] && echo yes || echo no)"
grep -q "no patch for AppB" "$T/log" && echo "ok    the log names the app" || { echo "FAIL  the log doesn't name AppB"; fail=1; }
cp "$T/AppB.keep" "$S/system/app/AppB.odex"

# an app whose odex isn't an odex
cp "$S/system/app/AppA.odex" "$T/AppA.keep"; cp "$S/system/app/AppA.apk" "$S/system/app/AppA.odex"
check "a file that isn't an odex: no universal build" "rc=1" "$(run_build XQ9.USA.0000.V015.012.260507 | head -1)"
cp "$T/AppA.keep" "$S/system/app/AppA.odex"

# another stock library
cp "$S/system/lib/libtest.so" "$T/lib.keep"; echo x >> "$S/system/lib/libtest.so"
check "another stock library: no universal build" "rc=1" "$(run_build XQ9.USA.0000.V015.012.260507 | head -1)"
cp "$T/lib.keep" "$S/system/lib/libtest.so"
check "and back: builds again" "rc=0" "$(run_build XQ9.USA.0000.V015.012.260507 | head -1)"
[ $fail = 0 ]
