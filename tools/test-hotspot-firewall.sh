#!/bin/sh
# Off-car test of the hotspot firewall service (packages/wireless-carplay-aa/svc/hotspot-firewall.sh):
# iptables and ip6tables stubbed with their rules in files (one "chain rule" per line).
#   tools/test-hotspot-firewall.sh [shell]   (default sh; CI also runs mksh)
set -e
SH=${1:-sh}
ROOT=$(cd "$(dirname "$0")/.." && pwd)
T=$(mktemp -d); trap 'rm -rf "$T"' EXIT
fail=0
ok() { if eval "$2"; then echo "ok    $1"; else echo "FAIL  $1"; fail=1; fi; }

mkdir -p "$T/bin"
# a tiny iptables: -S/-N/-X/-F/-A/-I/-D/-C on a file per version; chains are lines "chain NAME"
cat > "$T/bin/fakeipt" <<'EOF'
#!/bin/sh
f=$1; shift
[ -f "$f.gone" ] && exit 1
touch "$f"
op=$1; ch=$2; shift 2
rule="$*"
case "$op" in
  -S) grep -qx "chain $ch" "$f" || exit 1; grep "^$ch " "$f"; exit 0 ;;
  -N) grep -qx "chain $ch" "$f" && exit 1; echo "chain $ch" >> "$f" ;;
  -X) grep -qx "chain $ch" "$f" || exit 1; grep -q "^$ch " "$f" && exit 1
      grep -vx "chain $ch" "$f" > "$f.t" || true; mv "$f.t" "$f" ;;
  -F) grep -qx "chain $ch" "$f" || exit 1; grep -v "^$ch " "$f" > "$f.t" || true; mv "$f.t" "$f" ;;
  -A) grep -qx "chain $ch" "$f" || exit 1
      # an iptables without the tcp match's ! --syn refuses the rule ($f.nosyn)
      case "$rule" in *"! --syn"*) [ -f "$f.nosyn" ] && exit 1 ;; esac
      echo "$ch $rule" >> "$f" ;;
  -I) n=$1; shift; rule="$*"; grep -qx "chain $ch" "$f" || exit 1
      { grep -vx "chain $ch" "$f" | grep -v "^$ch " || true; echo "chain $ch"; echo "$ch $rule"; grep "^$ch " "$f" || true; } > "$f.t"; mv "$f.t" "$f" ;;
  -D) grep -qxF "$ch $rule" "$f" || exit 1
      awk -v l="$ch $rule" 'BEGIN{d=0} $0==l && !d {d=1; next} {print}' "$f" > "$f.t"; mv "$f.t" "$f" ;;
  -C) grep -qxF "$ch $rule" "$f" || exit 1 ;;
  *) exit 2 ;;
esac
EOF
printf '#!/bin/sh\nexec %s/bin/fakeipt %s/v4 "$@"\n' "$T" "$T" > "$T/bin/iptables"
printf '#!/bin/sh\nexec %s/bin/fakeipt %s/v6 "$@"\n' "$T" "$T" > "$T/bin/ip6tables"
# the sleep stand-in moves the uptime on by what was asked, and runs an onsleep hook once
printf '#!/bin/sh\necho "$1" >> %s/slept\nread -r u r < %s/uptime\necho "$((${u%%%%.*} + $1)).00 0.00" > %s/uptime\n[ -f %s/onsleep ] && sh %s/onsleep; rm -f %s/onsleep\nexit 0\n' "$T" "$T" "$T" "$T" "$T" "$T" > "$T/bin/sleep"
chmod +x "$T/bin/"*
echo "1000.00 900.00" > "$T/uptime"
# sleep as a function: some mksh builds (Fedora's) have sleep as a builtin, which would skip the stand-in (and wait)
sed -e "s|^export PATH=.*|export PATH=$T/bin:/usr/bin:/bin|" -e "/^export PATH=/a sleep() { \"$T/bin/sleep\" \"\$@\"; }" \
    -e "s|/proc/uptime|$T/uptime|g" \
    "$ROOT/packages/wireless-carplay-aa/svc/hotspot-firewall.sh" > "$T/fw.sh"

stock() {   # the stock whitelist firewall, as the car loads it
    for v in v4 v6; do
        printf 'chain INPUT\nINPUT -i lo -j ACCEPT\nINPUT -j WLIST_IN\nchain WLIST_IN\nWLIST_IN -i wlan0 -j WL_WLAN0_IN\nchain WL_WLAN0_IN\n' > "$T/$v"
    done
}
plain() { for v in v4 v6; do printf 'chain INPUT\n' > "$T/$v"; done; }
# replies() <v4|v6>: each of the 8 TCP source-port rules takes no new connection (! --syn); no other rule has it
replies() {
    [ "$(grep -c '^EVG_HOTSPOT -p tcp -m tcp --sport [0-9:]* ! --syn -j ACCEPT$' "$T/$1")" = 8 ] \
        && [ "$(grep -c -e '--syn' "$T/$1")" = 8 ]
}
run() { rm -f "$T/slept"; FW_PASSES=$1 "$SH" "$T/fw.sh" > "$T/out" 2>&1; }

stock; run 1
ok "whitelist car: jump first in INPUT (IPv4, hotspot addresses only)" 'grep "^INPUT " "$T/v4" | head -1 | grep -qx "INPUT -i wlan0 -s 192.168.0.0/24 -j EVG_HOTSPOT"'
ok "whitelist car: jump first in INPUT (IPv6, link-local only)" 'grep "^INPUT " "$T/v6" | head -1 | grep -qx "INPUT -i wlan0 -s fe80::/10 -j EVG_HOTSPOT"'
ok "CarPlay and Android Auto ports both ways, tcp and udp" '[ "$(grep -c "^EVG_HOTSPOT -p" "$T/v4")" = 32 ] && grep -qx "EVG_HOTSPOT -p tcp -m tcp --dport 7000 -j ACCEPT" "$T/v4" && grep -qx "EVG_HOTSPOT -p tcp -m tcp --dport 40515 -j ACCEPT" "$T/v4" && grep -qx "EVG_HOTSPOT -p udp -m udp --sport 5000:5001 -j ACCEPT" "$T/v4"'
ok "TCP from a listed source port: replies only, so it can't reach other ports" 'replies v4 && replies v6'
ok "ICMPv6 on IPv6 only" 'grep -q icmpv6 "$T/v6" && ! grep -q icmpv6 "$T/v4"'
ok "stock rules untouched" 'grep -qx "INPUT -j WLIST_IN" "$T/v4" && grep -qx "WLIST_IN -i wlan0 -j WL_WLAN0_IN" "$T/v4"'
ok "logged" 'grep -q "IPv4: stock whitelist firewall found" "$T/out"'
cp "$T/v4" "$T/v4.before"
run 3
ok "nothing added again when in place" 'cmp -s "$T/v4" "$T/v4.before"'
# the stock firewall reloads: flushes INPUT and puts its own rules back
echo 'grep -v "^INPUT -i wlan0" '"$T"'/v4 > '"$T"'/x; mv '"$T"'/x '"$T"'/v4' > "$T/onsleep"
run 2
ok "put back after the stock firewall reloads" '[ "$(grep -c "^INPUT -i wlan0 -s 192.168.0.0/24 -j EVG_HOTSPOT" "$T/v4")" = 1 ] && [ "$(grep -c "^EVG_HOTSPOT " "$T/v4")" = 32 ]'
sh -c "cd '$T' && FW_PASSES=1 '$SH' '$T/fw.sh' remove" > /dev/null 2>&1
ok "remove: no jump and no chain left" '! grep -q EVG_HOTSPOT "$T/v4" && ! grep -q EVG_HOTSPOT "$T/v6"'
ok "remove: stock rules kept" 'grep -qx "INPUT -j WLIST_IN" "$T/v4"'
plain; run 2
ok "no whitelist firewall: nothing added" '! grep -q EVG_HOTSPOT "$T/v4" && ! grep -q EVG_HOTSPOT "$T/v6" && grep -q "no stock whitelist" "$T/out"'
echo "30.00 20.00" > "$T/uptime"; plain; run 2
ok "no whitelist firewall yet, just after power-on: looks again every 10 s" '[ "$(cat "$T/slept")" = 10 ]'
# 3 minutes of 10 s looks from the service's start (18 of them), then every 5 minutes
echo "1000.00 900.00" > "$T/uptime"; plain; run 20
ok "no whitelist firewall, 3 minutes after the service started: looks again every 5 minutes" '[ "$(grep -c "^10$" "$T/slept")" = 18 ] && [ "$(sed -n 19p "$T/slept")" = 300 ] && [ "$(wc -l < "$T/slept")" = 19 ]'
# the service restarted long after power-on, while the stock firewall reloads (its chains gone
# for a moment): still looks every 10 s, so the rules come back within 10 s, not 5 minutes
echo "1000.00 900.00" > "$T/uptime"; plain; printf 'printf "chain INPUT\\nINPUT -j WLIST_IN\\nchain WLIST_IN\\n" > %s/v4\n' "$T" > "$T/onsleep"; run 3
ok "restarted during a stock firewall reload, long after power-on: still every 10 s, rules back" '[ "$(tr "\n" " " < "$T/slept")" = "10 10 " ] && grep -q "^INPUT -i wlan0 -s 192.168.0.0/24 -j EVG_HOTSPOT" "$T/v4"'
echo "1000.00 900.00" > "$T/uptime"; stock; run 2
ok "whitelist car: checked every 10 s" '[ "$(cat "$T/slept")" = 10 ]'
# the stock firewall reloading, its chains gone for a moment: still checked every 10 s
stock; printf 'for v in v4 v6; do printf "chain INPUT\\n" > %s/$v; done\n' "$T" > "$T/onsleep"; run 3
ok "whitelist car, a pass while the stock firewall reloads: still every 10 s" '[ "$(tr "\n" " " < "$T/slept")" = "10 10 " ]'
# the same past the first 3 minutes (no settle window): the whitelist once seen keeps it to 10 s
export FW_SETTLE_S=0
echo "1000.00 900.00" > "$T/uptime"; stock; run 3
ok "whitelist car, past the first 3 minutes: still every 10 s" '[ "$(tr "\n" " " < "$T/slept")" = "10 10 " ]'
stock; printf 'for v in v4 v6; do printf "chain INPUT\\n" > %s/$v; done\n' "$T" > "$T/onsleep"; run 3
ok "whitelist car, past the first 3 minutes, a pass during a reload: still every 10 s" '[ "$(tr "\n" " " < "$T/slept")" = "10 10 " ]'
unset FW_SETTLE_S
stock; touch "$T/v6.gone"; run 1
ok "no ip6tables: IPv4 still done, no error" 'grep -q EVG_HOTSPOT "$T/v4" && ! grep -qi "not found" "$T/out"'
sh -c "cd '$T' && FW_PASSES=1 '$SH' '$T/fw.sh' remove" > "$T/out" 2>&1
ok "no ip6tables: remove takes IPv4's out, no error" '! grep -q EVG_HOTSPOT "$T/v4" && [ ! -s "$T/out" ]'
rm -f "$T/v6.gone"
# an iptables that refuses ! --syn: the TCP reply rules are missing, so the rules aren't taken as in
# place (it says so and tries again) rather than reported as opened
stock; touch "$T/v4.nosyn" "$T/v6.nosyn"; run 1
ok "an iptables that refuses ! --syn: not reported as opened, said and tried again" '! grep -q "CarPlay ports opened" "$T/out" && grep -q "could not put the hotspot rules in" "$T/out"'
rm -f "$T/v4.nosyn" "$T/v6.nosyn"
# the firewall appears only after the service starts (iptrules runs about 6 s after power-on)
plain; echo "printf 'chain WLIST_IN\n' >> $T/v4" > "$T/onsleep"; run 2
ok "firewall loaded after start: picked up on the next pass" 'grep -q "^INPUT -i wlan0 -s 192.168.0.0/24 -j EVG_HOTSPOT" "$T/v4"'
[ $fail = 0 ]
