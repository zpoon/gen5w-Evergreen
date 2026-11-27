#!/bin/sh
# Build the CarPlay EV routing native libraries (our own code, no manufacturer files):
#   libcarplayev.so        EV status in iAP2 VehicleStatus updates (native/ev, from
#                          isaacwisdom/egmp-carplay-ev-routing, GPL-3.0-or-later)
#   libcarplayidentity.so  the car's EV facts in the iAP2 identification message
#                          (native/identity, from Open-HMG/hmgapi-wireless-cp-aa, GPL-3.0-or-later)
# into packages/wireless-carplay-aa/comp/2_tbt/files/. Needs clang + ld.lld and a JDK (jni.h).
# Same sources, same bytes (no build id).
set -e
HERE=$(cd "$(dirname "$0")" && pwd)
OUT=${1:-$HERE/../../packages/wireless-carplay-aa/comp/2_tbt/files}
mkdir -p "$OUT"; OUT=$(cd "$OUT" && pwd)
CLANG=${CLANG:-clang}
JAVA_HOME=${JAVA_HOME:-$(dirname "$(dirname "$(readlink -f "$(command -v javac)")")")}
JNI="-I$JAVA_HOME/include -I$JAVA_HOME/include/linux"
T="--target=armv7a-linux-androideabi -mthumb -march=armv7-a -mfloat-abi=soft"
F="-Os -fPIC -ffreestanding -fno-builtin -fno-stack-protector -fno-unwind-tables -fno-asynchronous-unwind-tables -fvisibility=hidden -Wall -Wextra -Werror"
L="-shared -nostdlib -fuse-ld=lld -Wl,-z,now -Wl,--no-rosegment -Wl,--hash-style=sysv -Wl,--build-id=none -Wl,--no-undefined"
W=$(mktemp -d); trap 'rm -rf "$W"' EXIT
# stand-ins for the head unit's libc/libdl, only so the linker records the imports
printf '%s\n' 'int mprotect(void *p,unsigned n,int f){return 0;} int pthread_mutex_lock(void *p){return 0;} int pthread_mutex_unlock(void *p){return 0;}' > "$W/c.c"
printf '%s\n' 'void *dlopen(const char *p,int f){return 0;} void *dlsym(void *h,const char *s){return 0;}' > "$W/dl.c"
for s in c:libc dl:libdl; do
    "$CLANG" $T -shared -nostdlib -fuse-ld=lld -Wl,-soname,${s#*:}.so -o "$W/${s#*:}.so" "$W/${s%%:*}.c"
done
cd "$W"
"$CLANG" $T $F -I"$HERE/native/ev/compat" $JNI $L -Wl,-soname,libcarplayev.so -o "$OUT/libcarplayev.so" "$HERE/native/ev/bridge_jni.c" libdl.so
"$CLANG" $T $F -I"$HERE/native/ev/compat" $JNI $L -Wl,-soname,libcarplayidentity.so -o "$OUT/libcarplayidentity.so" "$HERE/native/identity/identity.c" libc.so libdl.so
md5sum "$OUT/libcarplayev.so" "$OUT/libcarplayidentity.so"
