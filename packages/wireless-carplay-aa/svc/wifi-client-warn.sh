#!/system/bin/sh
# Evergreen service wireless.carplay.aa/wifi-client-warn: a pop-up when the head
# unit's Wi-Fi client is on.
#
# Wireless CarPlay and Android Auto run over the head unit's own hotspot. The Wi-Fi
# chip can run the hotspot and a client connection only on one shared channel, so
# with the client on (Settings > Wi-Fi, or NEMESIS Manager's WiFi button) its scans
# and joins can take the hotspot off its channel: owners report CarPlay dropping
# and reconnecting every minute or two. This only warns. It reads one setting
# (wifi_on) and changes nothing.
#
# Pop-up once after each boot if the client is already on, and each time it is
# switched on. Nothing when the owner chose the client at install
# (LEAFIA-WIFI-CLIENT), or while Android is down (settings gives no answer).
# Output goes to NEMESIS's service log: nemesis log service wireless.carplay.aa/wifi-client-warn
# WIFIWARN_PASSES=N stops after N passes (host sandbox test; unset = forever).

export PATH=/data/nemesis/bin:/sbin:/vendor/bin:/system/sbin:/system/bin:/system/xbin

POLL_S=${WIFIWARN_POLL_S:-15}
# part 1's marker for the opt-in Wi-Fi client (comp/1_projection/scripts/common.sh)
OPTIN=/data/nemesis/backup/wireless.projection/wifi_client
MSG="Wi-Fi is on. Wireless CarPlay and Android Auto can drop every minute or two while it is. If that happens, turn Wi-Fi off in the head unit's Wi-Fi settings."

log() {
    echo "$(date) $1"
}

toast() {
    am broadcast -a com.hkmc.intent.action.TOAST -e com.hkmc.intent.extra.TOAST_MESSAGE "$1" --ez com.hkmc.intent.extra.TOAST_POPUPSHOWING true >/dev/null 2>&1 || true
}

# on / off / empty (no answer: Android down). 1 = on, 2 = on despite airplane
# mode; 0 and 3 are off.
wifi_state() {
    local _v
    _v=$(settings get global wifi_on 2>/dev/null) || return 0
    case "$_v" in
        1|2) echo on ;;
        0|3|null) echo off ;;
    esac
}

log "wifi-client-warn started"
LAST=""      # last known state; empty until Android answers
PENDING=0    # on seen at boot: warn on the next pass, once the UI is up
while true; do
    _s=$(wifi_state)
    if [ -n "$_s" ] && [ ! -f "$OPTIN" ]; then
        if [ "$_s" = on ]; then
            if [ "$PENDING" = 1 ]; then
                log "Wi-Fi client is on: warned"
                toast "$MSG"
                PENDING=0
            elif [ -z "$LAST" ]; then
                PENDING=1            # first answer after boot
            elif [ "$LAST" = off ]; then
                log "Wi-Fi client switched on: warned"
                toast "$MSG"
            fi
        else
            [ "$LAST" = on ] && log "Wi-Fi client switched off"
            PENDING=0
        fi
        LAST=$_s
    fi
    if [ -n "$WIFIWARN_PASSES" ]; then
        WIFIWARN_PASSES=$((WIFIWARN_PASSES - 1))
        [ "$WIFIWARN_PASSES" -le 0 ] && exit 0
    fi
    sleep "$POLL_S"
done
