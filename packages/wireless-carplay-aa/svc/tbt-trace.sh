#!/system/bin/sh
# Evergreen service wireless.carplay.aa/tbt-trace: keeps the turn-by-turn trace.
#
# Only when the package was installed with EVERGREEN-TRACE on the install drive
# (scripts/common.sh trace_setup writes the flag below). Then DiPO logs each raw
# CarPlay route guidance, maneuver and lane message (numbers only; strings only as
# their count, so no road names) as "Leafia: trace ..." lines, and this writes every
# Leafia log line to TRACE_DIR from boot on: the log buffer itself only holds seconds
# on these units. The last 6 hours, one file per hour. NEMESIS Manager's
# Logs > Copy to USB and the kit's private logs take them.
# Without the flag it only waits (mode=restart would start it again if it ended).

export PATH=/data/nemesis/bin:/sbin:/vendor/bin:/system/sbin:/system/bin:/system/xbin

FLAG=/data/nemesis/wireless.carplay.aa.trace
DIR=/data/nemesis/logs/evergreen-trace

while [ ! -f "$FLAG" ]; do
    sleep 3600
done
umask 077
mkdir -p "$DIR" || exit 1
echo "$(date) trace on: $DIR/trace.log"
# logcat's own -f is not used: on these units logcat stops reading options at the
# first filter spec, so "-s Leafia:V -f ..." ignored -f and wrote to stdout (a US
# Ioniq 5, 2026-11-24), and with the filter last a test wrote every tag to the file.
# The filter-first form does filter, so its stdout goes to the file, and the file
# turns over every hour: trace.log, then trace.log.1 ... trace.log.5 (6 hours).
# stopped by NEMESIS (uninstall, update): take the logcat along
_p=
trap 'kill $_p $_s 2>/dev/null; exit 0' TERM INT
while :; do
    for i in 4 3 2 1; do
        [ -f "$DIR/trace.log.$i" ] && mv "$DIR/trace.log.$i" "$DIR/trace.log.$((i + 1))"
    done
    [ -f "$DIR/trace.log" ] && mv "$DIR/trace.log" "$DIR/trace.log.1"
    logcat -v time -s Leafia:V > "$DIR/trace.log" 2>&1 &
    _p=$!
    sleep 3600 &
    _s=$!
    wait $_s
    kill $_p 2>/dev/null
    wait $_p 2>/dev/null
done
