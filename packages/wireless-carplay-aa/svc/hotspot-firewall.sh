#!/system/bin/sh
# Evergreen service wireless.carplay.aa/hotspot-firewall: lets wireless CarPlay
# through the stock firewall on cars that have one.
#
# Some cars (the US Ioniq 6) run a whitelist firewall (init service iptrules, about
# 6 s after power-on): policy DROP, and WLIST_IN sends each interface to its own
# chain. The hotspot (wlan0) only gets DNS, DHCP and Bonjour; the CarPlay ports are
# open only on ncm0 (wired CarPlay). So an iPhone finds the car over the hotspot,
# then its connection is dropped; an Android phone gets the hotspot's details over
# Bluetooth, joins, and its connection to the head unit is dropped the same way.
#
# On such a car (chain WLIST_IN present) this puts its own chain EVG_HOTSPOT first in
# INPUT, for packets coming in on wlan0 from the hotspot's own addresses only
# (192.168.0.0/24, and link-local fe80::/10 for IPv6, which iPhones use for CarPlay),
# accepting the same ports the stock firewall opens for wired CarPlay (either way,
# as the stock rules do, but TCP from one of those source ports only when it isn't a
# new connection), the port wireless Android Auto's phone connects to, and,
# for IPv6, ICMPv6 (neighbour discovery). Nothing else
# changes. The rules live in memory only: they are gone after a restart, and the
# stock firewall can load or reload after this starts, so they are checked every
# POLL_S seconds and put back when missing. Uninstall (scripts/preun.sh) takes them
# out with "hotspot-firewall.sh remove". On cars without the whitelist it does nothing:
# it looks for it every POLL_S seconds for the first SETTLE_S seconds after it starts
# (power-on, or a restart of the service while the stock firewall may be reloading),
# then every IDLE_S seconds, in case it loads later; each look is one iptables and
# one ip6tables. Once a whitelist has been seen it keeps to POLL_S, even through a pass
# that misses it while the stock firewall reloads.
# Output goes to NEMESIS's service log: nemesis log service wireless.carplay.aa/hotspot-firewall
# FW_PASSES=N stops after N passes (host sandbox test; unset = forever).

export PATH=/data/nemesis/bin:/sbin:/vendor/bin:/system/sbin:/system/bin:/system/xbin

POLL_S=${FW_POLL_S:-10}
SETTLE_S=${FW_SETTLE_S:-180}
IDLE_S=${FW_IDLE_S:-300}
CHAIN=EVG_HOTSPOT
# CarPlay: the ports the stock firewall opens for wired CarPlay. Android Auto: 40515,
# the port GPM tells the phone to connect to (WirelessExplorer, WifiData.setPort).
# 7000 stays last: present() checks the chain's last rule, and its TCP reply rule.
PORTS="40515 5000:5001 5020 6000:6003 6011 6020 6030 7000"

log() {
    echo "$(date) $1"
}

# ipt <4|6> args...: iptables or ip6tables, quiet
ipt() {
    local _v=$1; shift
    if [ "$_v" = 6 ]; then ip6tables "$@" >/dev/null 2>&1; else iptables "$@" >/dev/null 2>&1; fi
}

src() {
    if [ "$1" = 6 ]; then echo fe80::/10; else echo 192.168.0.0/24; fi
}

# whitelist <4|6>: the stock whitelist firewall is loaded (and so the tool is there)
whitelist() {
    ipt "$1" -S WLIST_IN
}

# present <4|6>: our jump, the last TCP reply rule and the last rule of our chain are in place
# (an iptables that refused ! --syn would leave the TCP reply rules out, and that shows here)
present() {
    ipt "$1" -C INPUT -i wlan0 -s "$(src "$1")" -j $CHAIN || return 1
    ipt "$1" -C $CHAIN -p tcp -m tcp --sport 7000 ! --syn -j ACCEPT || return 1
    ipt "$1" -C $CHAIN -p udp -m udp --sport 7000 -j ACCEPT
}

# drop <4|6>: take our jump(s) and chain out
drop() {
    local _n=0
    while ipt "$1" -D INPUT -i wlan0 -s "$(src "$1")" -j $CHAIN; do
        _n=$((_n + 1)); [ "$_n" -ge 20 ] && break
    done
    ipt "$1" -F $CHAIN
    ipt "$1" -X $CHAIN
}

# apply <4|6>: our chain, filled first, then the jump to it
apply() {
    local _v=$1 _p _x _y
    drop "$_v"
    ipt "$_v" -N $CHAIN || return 1
    [ "$_v" = 6 ] && ipt 6 -A $CHAIN -p icmpv6 -j ACCEPT
    for _x in dport sport; do
        for _p in tcp udp; do
            for _y in $PORTS; do
                if [ "$_x" = sport ] && [ "$_p" = tcp ]; then
                    # replies only: a new connection from one of these source ports would
                    # otherwise reach every port on the head unit
                    ipt "$_v" -A $CHAIN -p tcp -m tcp --sport "$_y" ! --syn -j ACCEPT
                else
                    ipt "$_v" -A $CHAIN -p $_p -m $_p --$_x "$_y" -j ACCEPT
                fi
            done
        done
    done
    ipt "$_v" -I INPUT 1 -i wlan0 -s "$(src "$_v")" -j $CHAIN
}

if [ "$1" = remove ]; then
    for v in 4 6; do drop $v; done
    exit 0
fi

log "hotspot-firewall started"
STATE4=""; STATE6=""
seen=""
started=0
read -r started _ < /proc/uptime 2>/dev/null || true
started=${started%%.*}
while true; do
    for v in 4 6; do
        if whitelist $v; then
            seen=1
            if ! present $v; then
                if apply $v && present $v; then
                    log "IPv$v: stock whitelist firewall found, CarPlay ports opened on the hotspot"
                else
                    log "IPv$v: could not put the hotspot rules in (will try again)"
                fi
            fi
            s=on
        else
            s=off
        fi
        if [ "$v" = 4 ]; then
            [ "$s" = off ] && [ "$STATE4" != off ] && log "IPv4: no stock whitelist firewall: nothing to do"
            STATE4=$s
        else
            [ "$s" = off ] && [ "$STATE6" != off ] && log "IPv6: no stock whitelist firewall: nothing to do"
            STATE6=$s
        fi
    done
    if [ -n "$FW_PASSES" ]; then
        FW_PASSES=$((FW_PASSES - 1))
        [ "$FW_PASSES" -le 0 ] && exit 0
    fi
    if [ -n "$seen" ]; then
        sleep "$POLL_S"
    else
        up=0
        read -r up _ < /proc/uptime 2>/dev/null || true
        up=${up%%.*}
        if [ $((${up:-0} - ${started:-0})) -lt "$SETTLE_S" ]; then sleep "$POLL_S"; else sleep "$IDLE_S"; fi
    fi
done
