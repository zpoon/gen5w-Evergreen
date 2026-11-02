# Investigation: wireless CarPlay with two iPhones

Status: **open**. Hypotheses only, from reading code; nothing confirmed on a car
yet. No package changes have been made for this.

## Reported symptoms

1. **Second phone can't connect after the first one leaves.** Phone A is on
   wireless CarPlay, then goes away (the passenger gets out and walks off).
   Phone B, which is also in the car, can't start CarPlay until the head unit
   restarts, however long you wait.
2. **First phone drops out while a second phone is connected.** Phones A and B
   are both connected over Bluetooth, and A is on wireless CarPlay. A's CarPlay
   drops for a couple of seconds every couple of minutes.

## What the bridge does (and why it matters here)

On these US/Canada head units, wireless CarPlay starts over Bluetooth, which the
stock iAP2 server can't do by itself. Part `3_bridge` installs bridge builds of
`HKMC_DiPO` and `Iap2ServerApp` (`com.ev6.cpwl`, logs as `EV6CPWL`). The bridge:

- opens an SPP link to an iPhone when the phone connects over Bluetooth,
- carries iAP2 between that link and the iAP2 server,
- brings up the hotspot, so the phone can join it and start the CarPlay session,
- hands iAP2 over to the CarPlay session's own channel once the session runs.

**The bridge's source isn't in this repo.** It lives in the original author's
private tools, and the repo ships it only as `*.bridge.lpd` deltas against
each car's stock apps. The readable reference is HMG-API's re-implementation,
[`mods/wireless-carplay-aa/src/hmgapi/mods/wireless/dipo/Bridge.java`](https://github.com/VysseCodes/HMG-API/blob/main/mods/wireless-carplay-aa/src/hmgapi/mods/wireless/dipo/Bridge.java)
(AGPL-3.0). It says it works from the same bridge build, and it uses the same
property, `persist.ev6.cpwl.enable`. The analysis below assumes Leafia's bridge
behaves the same way. That needs confirming against Leafia's own bridge code;
see "Getting Leafia's bridge code" below.

The bridge tracks **one phone** in global state: `sAddr` (that phone's
Bluetooth address), `sSession` (an iAP2 session over SPP is up), and
`sCpWireless` / `sCpClient` (a wireless CarPlay session is up).

## Symptom 1: the second phone is stuck until restart

### Hypothesis 1a (most likely): nothing starts SPP for a phone that's already connected

The bridge only opens SPP to an iPhone in two cases:
- when the Bluetooth manager reports that phone **connecting**
  (`onBTCMDeviceConnectionEventChanged`, event 2), or
- when DiPO first registers with the Bluetooth manager (`onBtcmReady`, at
  start-up, for the one HFP-connected device).

`scheduleSppConnect` does nothing while a session is up (`sSession` or
`sCpWireless`). Here's what happens step by step:

1. **B connects while A is on CarPlay.** Phone B connects over Bluetooth while
   phone A's CarPlay is up. Its connect event arrives and is ignored.
2. **A leaves.** A's CarPlay session ends (`onCpSessionFinalized`), and SPP to A
   goes down (`onSppDown`).
3. **The restart path only looks at A.** The only follow-up is `onUsbGone()`. It
   rechecks `sAddr`, which is **A** (or nothing, if A's SPP dropped after the
   session ended), and only re-attaches if *A's* SPP is still up. Whichever order
   these happen in, nothing looks for other connected iPhones.
4. **B is never asked.** Phone B stays connected over Bluetooth the whole time,
   so it never sends a new connect event, and SPP to B is never opened.
5. **Only a restart helps.** A head unit restart re-runs `onBtcmReady` and the
   phones reconnect, so B gets its connect event. That matches "until HU
   restart, no matter how long I wait".

(If A's Bluetooth drops while its Wi-Fi session is still up, `onSppDown()`
keeps `sAddr` pointing at A, because it expects the session to carry on over
Wi-Fi.)

### Hypothesis 1b: A's wireless session never ends

If the stock CarPlay library never finalizes A's Wi-Fi session after A drops
off without disconnecting (no teardown, no timeout), `sCpWireless` stays true.
That blocks every new SPP connect. The symptom is the same.

### Telling 1a from 1b

The CarPlay session-finalized step should show in the log after A leaves (in
HMG-API's version: `CarPlay session finalized`). If it's there, the cause is 1a.
If it never appears, the cause is 1b.

### Quick test for the reporter

When B is stuck, **turn Bluetooth off and on again on phone B**, or disconnect
and reconnect the car in B's Bluetooth settings. This gives the bridge a fresh
connect event for B.
- If CarPlay then starts on B, it's **1a** (and this is also a workaround until
  it's fixed).
- If it still doesn't, it's probably **1b**.

### Fix direction (not done)

When a session ends, or SPP to the tracked phone goes down:
- clear `sAddr`,
- look up the iPhones still connected over HFP,
- call `scheduleSppConnect` for one of them.

`IbtcmGetHfpConnectedDevice` returns a single device, so it may need a way to
list every connected device. For 1b, it would also need its own timeout on a
wireless session whose phone has left both Bluetooth and the hotspot.

## Symptom 2: phone A drops while phone B is connected

In the bridge's logic, a second iPhone looks well guarded:
- `scheduleSppConnect` and `onSppUp` both return early while a session is up,
- `onSppDown` and `onSppData` ignore any address that isn't `sAddr`.

So the cause is more likely outside the bridge:

### Hypothesis 2a (most likely): phone B on the hotspot

The car's hotspot uses the same SSID and password for every phone. If phone B
has used wireless CarPlay in this car before, it may **auto-join the hotspot**
and try to start its own CarPlay session there. The stock CarPlay receiver
handles one session at a time, so each attempt from B could disrupt A for a few
seconds. Retrying every few minutes would fit "every couple of minutes".

### Hypothesis 2b: Bluetooth link juggling

The head unit's Bluetooth controller is keeping HFP and A2DP links to two
phones, plus SPP to A. Periodic profile reconnects or active-device switches for
B could disrupt A, or the stock DiPO might react to an HFP active-device change.
The bridge would ride out a short SPP drop for A (`onSppDown` keeps the Wi-Fi
session), but stock DiPO might not.

### Hypothesis 2c: radio airtime

There is one Wi-Fi radio. Heavy hotspot traffic from B (iCloud backups, app
updates) could starve A's CarPlay stream. That fits short stalls more than
real drops.

### Tests for the reporter

Try one change at a time, and note whether the drops stop:

| Change on phone B | Drops stop? It points to |
|---|---|
| Wi-Fi off (Bluetooth on) | 2a or 2c (hotspot) |
| Settings › General › CarPlay › this car › **Forget This Car** (keep Bluetooth pairing) | 2a (B's CarPlay attempts) |
| Bluetooth off (Wi-Fi on) | 2b (Bluetooth) |

Also useful: how regular the drops are (every 2 minutes exactly, or random),
and a **standard Leafia kit** (`leafia-kit.zip`) run right after a drop. It
only keeps about the last minute of the Android log. Look for the
`EV6CPWL`/bridge lines, DiPO session start and stop, and hotspot client
join/leave (`hostapd`/`dnsmasq`) at the time of the drop.

### Fix direction (not done)

Depends on the test results. For 2a, the options are:
- only accept a CarPlay session from the phone the bridge is tracking,
- limit the hotspot to one client while a session is up,
- stop handing out hotspot credentials to a second phone.

For 2b, it would need DiPO's stock handling of HFP device changes.

## Getting Leafia's bridge code

To change the bridge, someone needs the bridge build's code:
1. **Rebuild it off-car.** Use a car's stock files (the **port** kit's
   `LEAFIA/private/stock`) with `lpatch-host delta` and the car's
   `*.bridge.lpd`.
2. **Disassemble it.** Run `baksmali` on the rebuilt `classes.dex`, with the
   deodex flags in `CLAUDE.md`.
3. **Compare.** Check its handling against HMG-API's `Bridge.java`, to confirm
   or rule out the hypotheses above.

Any changes then become new `.bridge.lpd` deltas, made with
`tools/mkpatches.py`, for every car set. Before anyone runs them in a car, test
them on the mock head unit.

HMG-API's code is AGPL-3.0. This repo is GPL-3.0, and GPLv3 section 13 lets
the two be combined, but code copied from it stays under the AGPL. Note that in
`NOTICE.md` if any is used.
