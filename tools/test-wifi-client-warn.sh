#!/bin/sh
# Off-car test of the Wi-Fi client warning (packages/wireless-carplay-aa/svc/wifi-client-warn.sh):
# `settings` stubbed to answer from a file (no file = Android down), `am` records pop-ups.
#   tools/test-wifi-client-warn.sh [shell]   (default sh; CI also runs mksh)
set -e
SH=${1:-sh}
ROOT=$(cd "$(dirname "$0")/.." && pwd)
T=$(mktemp -d); trap 'rm -rf "$T"' EXIT
fail=0
ok() { if eval "$2"; then echo "ok    $1"; else echo "FAIL  $1"; fail=1; fi; }

mkdir -p "$T/bin"
printf '#!/bin/sh\necho "TOAST $*" >> %s/toasts\n' "$T" > "$T/bin/am"
printf '#!/bin/sh\n[ -f %s/wifi_on ] || exit 1\ncat %s/wifi_on\n' "$T" "$T" > "$T/bin/settings"
chmod +x "$T/bin/am" "$T/bin/settings"
sed -e "s|/data/nemesis/|$T/data/nemesis/|g" -e "s|^export PATH=.*|export PATH=$T/bin:/usr/bin:/bin|" \
    "$ROOT/packages/wireless-carplay-aa/svc/wifi-client-warn.sh" > "$T/warn.sh"
# script of states, one per pass ("down" = no answer); the stubbed sleep moves to the next
printf '#!/bin/sh\nn=$(cat %s/n); n=$((n+1)); echo $n > %s/n\nl=$(sed -n "${n}p" %s/states)\nif [ "$l" = down ]; then rm -f %s/wifi_on; else echo "$l" > %s/wifi_on; fi\n' \
    "$T" "$T" "$T" "$T" "$T" > "$T/bin/sleep"; chmod +x "$T/bin/sleep"
run() {   # run <states...>: first state before pass 1, the rest after each pass
    rm -f "$T/toasts" "$T/out"; echo 0 > "$T/n"
    : > "$T/states"; for s in "$@"; do echo "$s" >> "$T/states"; done
    "$T/bin/sleep"
    WIFIWARN_REPEAT=1 WIFIWARN_PASSES=$# "$SH" "$T/warn.sh" >> "$T/out" 2>&1
}
toasts() { [ -f "$T/toasts" ] && grep -c TOAST "$T/toasts" || echo 0; }

run 0 0 0
ok "client off: no pop-up" '[ "$(toasts)" = 0 ]'
run down down 0
ok "Android down: no pop-up and no error" '[ "$(toasts)" = 0 ] && ! grep -qi "not found\|error" "$T/out"'
run 1 1 1 1
ok "on at boot: one pop-up, on the second pass" '[ "$(toasts)" = 1 ]'
run down 1
ok "on at boot: no pop-up on the first answer alone" '[ "$(toasts)" = 0 ]'
run 0 1 1 1
ok "switched on: one pop-up" '[ "$(toasts)" = 1 ] && grep -q "switched on: warned" "$T/out"'
run 0 1 0 1 1
ok "switched on twice: two pop-ups" '[ "$(toasts)" = 2 ] && grep -q "switched off" "$T/out"'
run 2 2 2
ok "on despite airplane mode (2) counts as on" '[ "$(toasts)" = 1 ]'
run null 3 0
ok "unset and airplane-off (3) count as off" '[ "$(toasts)" = 0 ]'
ok "pop-up says what to do" 'run 0 1 1; grep -q "turn Wi-Fi off" "$T/toasts"'
mkdir -p "$T/data/nemesis/backup/wireless.projection"; : > "$T/data/nemesis/backup/wireless.projection/wifi_client"
run 0 1 1 1
ok "opted in with LEAFIA-WIFI-CLIENT: no pop-up" '[ "$(toasts)" = 0 ]'
rm -f "$T/data/nemesis/backup/wireless.projection/wifi_client"
rm -f "$T/toasts"; echo 0 > "$T/n"; printf '0\n1\n1\n' > "$T/states"; "$T/bin/sleep"
WIFIWARN_PASSES=3 "$SH" "$T/warn.sh" > "$T/out" 2>&1
ok "default: each warning is sent 3 times in a row (about 10 s on screen)" '[ "$(toasts)" = 3 ]'
[ $fail = 0 ]
