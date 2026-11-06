#!/bin/sh
# Off-car test of the EV log copier (packages/wireless-carplay-aa/svc/evlog-offload.sh):
# paths rewritten into a sandbox, `am` stubbed to record pop-ups.
#   tools/test-evlog-offload.sh [shell]   (default sh; CI also runs mksh)
set -e
SH=${1:-sh}
ROOT=$(cd "$(dirname "$0")/.." && pwd)
T=$(mktemp -d); trap 'rm -rf "$T"' EXIT
fail=0
ok() { if eval "$2"; then echo "ok    $1"; else echo "FAIL  $1"; fail=1; fi; }

mkdir -p "$T/bin" "$T/storage/usb0" "$T/storage/usb1"
printf '#!/bin/sh\necho "TOAST $*" >> %s/toasts\n' "$T" > "$T/bin/am"; chmod +x "$T/bin/am"
sed -e "s|/data/data/|$T/data/data/|g" -e "s|/storage/|$T/storage/|g" -e "s|/mnt/media_rw/|$T/mnt/media_rw/|g" \
    -e "s|^export PATH=.*|export PATH=$T/bin:/usr/bin:/bin|" "$ROOT/packages/wireless-carplay-aa/svc/evlog-offload.sh" > "$T/offload.sh"
EV=$T/data/data/com.google.android.projection.sink/files/evlog
run() { EVLOG_PASSES=${PASSES:-1} EVLOG_POLL_S=0 "$SH" "$T/offload.sh" >> "$T/out" 2>&1; }

# no EV build: nothing logged on the unit, a drive with the folder in
mkdir -p "$T/storage/usb1/egmp-aa-ev-logs"
PASSES=2 run
ok "no EV logs: no pop-up" '[ ! -s "$T/toasts" ]'
ok "no EV logs: the drive is untouched" '[ -z "$(ls -A "$T/storage/usb1/egmp-aa-ev-logs")" ]'

# EV build logging
mkdir -p "$EV"
printf '# egmp-aa-ev-log v2\nt_s,soc_half_pct\n0,92\n5,92\n' > "$EV/egmp-NEEV-20261104-001.csv"
run
ok "log copied to the drive with the folder" 'cmp -s "$EV/egmp-NEEV-20261104-001.csv" "$T/storage/usb1/egmp-aa-ev-logs/egmp-NEEV-20261104-001.csv"'
ok "drive without the folder untouched" '[ -z "$(ls -A "$T/storage/usb0")" ]'
ok "no temp file left" '! ls -a "$T/storage/usb1/egmp-aa-ev-logs" | grep -q "\.tmp$"'
ok "pop-up names the copy" 'grep -q "EV logs: 1 copied to the USB drive" "$T/toasts"'
ok "output says what was copied" 'grep -q "copied 1 log(s)" "$T/out"'
n=$(grep -c "copied 1 log" "$T/out")
run
ok "unchanged log not copied again" '[ "$(grep -c "copied 1 log" "$T/out")" = "$n" ]'
echo "10,91" >> "$EV/egmp-NEEV-20261104-001.csv"
rm -f "$T/toasts"
PASSES=3 run
ok "grown log copied again" 'cmp -s "$EV/egmp-NEEV-20261104-001.csv" "$T/storage/usb1/egmp-aa-ev-logs/egmp-NEEV-20261104-001.csv"'
ok "one pop-up per insertion across passes" '[ "$(grep -c TOAST "$T/toasts")" = 1 ]'
[ $fail = 0 ]
