# Review: car-facing calls in the EV features (ev/)

Required by `CLAUDE.md`: "Vehicle commands only through the stock services, and
each new one gets its own review." This covers every binder call `ev/` makes
from inside GPM, as imported from egmp-aa-ev-feat v0.2.1 (commit `698cf3b`).

**Verdict:** the three preconditioning **commands are approved as they are.**
Evergreen needs **three changes before release**, all about the reads and the
logs, not the commands. They're listed under "Required changes".

## Commands (writes)

All in `ev/gpm-ev/src/.../Precond.java` (`HkmcVehicle.write`), sent to the stock
HEV service `com.hkmc.micom.hev` (`com.hkmc.hev.IHEVService`). These are the
same calls the car's own navigation makes when routing to a charger, and the
same ones the Precondition app (paytondevs/gen5w-preconditioning) sends.

| Txn | Method (from the car's framework) | Values sent | Effect |
|---|---|---|---|
| 65 | `setBattCondRouteDis(km)` | live distance to the charger, 0–2046; **2047** = invalid (cancel) | the BMS's "charger N km ahead" input |
| 66 | `setBattCondRemainTime(min)` | live time to the charger, 0–1022; **1023** = invalid (cancel) | "charger M min ahead" |
| 62 | `setBattCondEvStation(flag, type)` | **(2, 3)** once to start, **(0, 0)** to cancel | station event. The service resets it to (7,7) by itself after 120 ms, so it's a pulse |

The car's BMS decides whether and when to heat. These calls only describe the
route, and nothing overrides the car's own logic.

### Guards (checked in the code)

- **Allowlist:** `write()` rejects anything except txn 62 with two values, or
  65/66 with one value.
- **Firmware match:** writes are sent only when `automotive.odex` and
  `automotive-service.odex` (the files that define these numbers) match the
  SHA-256 of the verified Ioniq 5 US 260507 files, and the SDK is 19. On any
  other firmware the feature never sends a command.
- **Right service:** every call checks the binder's interface descriptor
  first.
- **Car-side off switch:** Start needs the car's own *battery conditioning*
  setting on (HEV flag 94 = 2), READY (flag 44 = 1), and the car's indicator
  Off (BCM 109 = 0). Turning the setting off cancels a live request.
- **Cancel on everything that ends a route:** route ended, target gone or no
  longer a DC charger over 50 kW, arrival (< 200 m), AA session end, GPM
  shutdown, READY lost, setting off, car status unreadable for 5 minutes,
  car Active → Off.
- **Crash safety:** an ownership journal is written and fsynced before the
  first command. After a crash, the next start only ever **cancels**. A failed
  cancel is retried 12 times, 5 s apart, and the journal stays until the car
  reads Off.
- **Limits:** at most 3 starts per route. If the indicator is already Active
  and Evergreen didn't start it (the car's own navigation, or the Precondition
  app), it stays hands-off.
- **Testing:** 82 host checks (`ev/gpm-ev/test/PrecondTest.java`). Verified on
  a 2022 Ioniq 5 on 260507: Off → Active → Off, and cancel within ~2.5 s when
  the route ends.

**Conflict to handle:** the Precondition app sends the same commands for
manual preconditioning. The hands-off rule covers "it's already Active". But
if both start within the same moment, each could see Off. That's low risk,
because both send the same profile and the BMS treats them as one request.
Add it to the car test list: start manual preconditioning in the Precondition
app, then route to a charger in Maps. Evergreen should stay hands-off.

## Reads

All in `ev/gpm-ev/src/.../EvCar.java` and `Precond.java`. All are getters.

| Service | Txn | Method | Used for |
|---|---|---|---|
| HEV `com.hkmc.micom.hev` | 3 | `getHEVStatus(flag)` | energy, SOC, READY, the conditioning setting, charging state, trip energy |
| BCM `com.hkmc.micom.bcm` | 109 | conditioning indicator | Precond state |
| BCM | 1 | `registerBCMListener` | a passive listener for drive mode. It deliberately never calls `getDriveMode()` (txn 0xc), which would send a MICOM request and can pop up the drive-mode screen |
| hscan `tm_hscan_service` | 0x0b, 0xd6, 0x2f | `getCarSpeed`, `getXEV_Bms_GDS_SOH`, `getVIN` | speed, health, and the VIN model part (see below) |
| DATC `com.hkmc.micom.datc` | 0x29, 0x06 | `getVRClimateStatus(flag)`, `isUnitCelsius` | climate state for the energy model and logs |
| Cluster | n/a | `NavigationCluster.requestBatteryInfoReq()` | the nav battery packet (pack temp, outside temp, available energy, range) |
| Android | n/a | `LocationManager.getLastKnownLocation("gps")` | **altitude change only**. Position and time are never logged |

## Required changes (before an Evergreen release)

All three are done on branch `ev-import` (2026-11-04); details after each.

1. **Gate the reads like the writes.** `EvCar` calls HEV, BCM, hscan and DATC by
   number with only a descriptor check. On a firmware where the numbers moved,
   a "getter" number could land on a different method, maybe a setter, which
   is the risk Battery Watchdog's lookup-by-name exists for. Evergreen only
   installs the EV build where the stock GPM matches, so today it can't reach
   another firmware. But GPM matching doesn't prove the framework matches.
   - **Fix:** run the same SHA-256 check (`automotive.odex`,
     `automotive-service.odex`) before any HEV, BCM or DATC call, plus
     `com.hkmc.ext.hcan.odex` (where hscan is defined) before hscan calls, or
     look the hscan getters up by name. With no match, EV routing still works
     from the cluster packet, with fewer inputs.
   - **Done:** `EvCar` looks every number up by method name in the car's own
     interface classes (`IHEVService$Stub.TRANSACTION_getHEVStatus`, the same
     for `IDATCService`, `IBCMService` and `IBCMListener`), so the reads need no
     hash: on any framework they reach the method they name, or read "unknown"
     if it isn't there. The telematics interface (hscan) lives in
     `com.hkmc.ext.hcan`, which GPM may not load. If it can't be found by name,
     the 260507 numbers are used only when that library's md5 is the Ioniq 5 US
     260507 one (`c4638b2b…`, from HMG-API's map). `Precond`'s own reads (HEV 3,
     BCM 109) now go through its firmware check, like its commands.
2. **No VIN.** `EvCar` reads the VIN (`getVIN`, hscan 0x2f) and logs characters
   1–8 and 10. Those identify the model and year, not the car, and the serial
   is never stored. But Evergreen's rules say never collect the VIN.
   - **Fix:** remove the `getVIN` call, and take `vin_model` from the firmware
     product id (`ro.build.product`, already in the log header), or drop the
     field. The log format version and `tools/evlog.py` change with it.
   - **Done:** no `getVIN` call; the header has no `vin_model` (the product id
     already names the car). `tools/evlog.py` still reads older files that
     have it. The format stays v2: the key was always optional.
3. **One log-offload service for Evergreen.** `evlog-offload.sh` becomes
   Evergreen's `[service.0]`, using names from Evergreen's package
   (`wireless.carplay.aa`) rather than `aa.ev.model`. It copies only
   `egmp-*.csv` logs to a drive folder named `egmp-aa-ev-logs/` (name kept, as
   users know it).
   - **Done:** `packages/wireless-carplay-aa/svc/evlog-offload.sh`, declared as
     `[service.0]` (`wireless.carplay.aa/evlog-offload`). Without an EV log
     folder it touches nothing and shows no pop-up; it idles rather than
     exiting, since NEMESIS gives up on a service that exits five times.

## Not changed (noted)

- **GPS:** the last known position is read only to compute an altitude change.
  Position and fix time never leave `EvCar`, and the log has no location.
  That's acceptable; it can be dropped later if anyone objects.
- **Energy model sent to the phone:** `EvModelSender` sends a vehicle energy
  model to Google Maps over Android Auto (sensor 23). That isn't a car command.
  It carries battery capacity, energy and outside temperature, which Maps uses
  for EV routing.
