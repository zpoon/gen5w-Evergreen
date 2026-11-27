#!/system/bin/sh
. ./scripts/common.sh
# every way out of this run starts again whatever it, or an earlier run, stopped
trap apps_release EXIT
log "preuninstall wireless.carplay.aa"
check_addons || exit 1
_rev=$(installed_parts_rev)
log "undoing: $_rev"
apps_hold "$_rev"
uninstall_parts "$_rev" || exit 1
apps_release
rm -f "$PARTS_FILE"
# the opt-in flags (EVERGREEN-TRACE, EVERGREEN-SCREEN-RECOVER, EVERGREEN-LANES-ID): the new version decides again on an update
rm -f "$TRACE_FLAG" "$SCREEN_FLAG" "$LANEID_FLAG"
# the hotspot firewall rules (memory only; on an update the new version's service
# puts them back within seconds)
sh ./svc/hotspot-firewall.sh remove && log "hotspot firewall rules taken out (if there were any)"
# On an update the new version keeps ADB over network as it is: putting the stock
# switch back would restart adbd and end an `adb shell` running the update (#17).
if updating; then
    log "update: ADB over network left as it is for the new version"
else
    adb_net_restore
fi
sync
log "all parts back to stock - reboot the head unit to finish"
exit 0
