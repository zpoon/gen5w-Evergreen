# CarPlay EV routing

Apple Maps EV routing for Evergreen, from Isaac Wisdom's
[egmp-carplay-ev-routing](https://github.com/isaacwisdom/egmp-carplay-ev-routing)
(an HMG-API mod) and the identification gate of HMG-API's wireless mod
(Open-HMG/hmgapi-wireless-cp-aa). Both GPL-3.0-or-later; see `NOTICE.md`.

## What runs on the car

- `libiap2session.so`, EV build (md5 `b32703e6…`): the stock library (`fc7cb675…`, the
  same on every car seen) with `recipes/carplay-ev-identification.recipe` applied by
  `tools/elf-addseg.py`: a new R+X segment and a `b.w` at
  `iAP2SessionPacketMakePacketUsingParamListNew` (0x1aa04) into the gate, which hands the
  identification to `libcarplayidentity.so` (VehicleInformation: engine electric,
  CCS and AC connectors with their power). The wireless mod's other gate ("group13") isn't
  used. Shipped as `patches/common/libiap2session.ev.lpd`, a `2_tbt+ev file` line in the
  EV sets (neev, neev23_260903, ev6, ev6_ca).
- `libcarplayev.so` (Isaac's `ev_extension.c`, `bridge_core.c`, `bridge_jni.c`, unchanged)
  and `libcarplayidentity.so` (`identity.c`, `recipe_gate.s`), our builds, in
  `packages/wireless-carplay-aa/comp/2_tbt/files/`; part 2 puts them in `/system/lib` with
  the EV library and removes them on uninstall.
- Iap2ServerApp, on every set (turn-by-turn and bridge builds): `LeafiaCarPlayEv`, called
  from `Iap2Service.onCreate/onDestroy` and `Iap2InitInformationMsg.checkSupportsFeatures`.
  It does nothing unless both libraries are there, the session library is exactly the EV
  build, the car's framework is one whose numbers were checked (the Ioniq 5 US 260507 and
  260903, the EV6 US and Canada) and `ro.build.product` has a profile. Then it configures the
  identification and turns on `iAP2UsedVehicleInformation`/`iAP2UsedVehicleStatus`, and a
  10 s worker sends VehicleStatus (energy, battery level, range, charging/consumption
  models) read from the stock services: `TM_HSCANAdapter` and `HEVManager` transactions
  looked up by name. Reads only, no vehicle commands. Logs `Leafia: CarPlay EV: ...`.

## Rebuilding

    ev/carplay/build.sh        # the two native libraries (clang, armv7a, stub libc), reproducible
    ev/carplay/build-java.sh   # java/ -> smali/ (javac android-19 + stubs, d8 --min-api 18)
    ev/carplay/gen-profiles.py # profiles/*.json -> LeafiaCarPlayEvProfiles.java
    ev/carplay/apply.py <deodexed Iap2ServerApp smali dir>   # idempotent

`stubs/` holds compile-only copies of the `com.tcc.iap2` interfaces (from the framework's
`com.tcc.iap2.jar`); nothing in it ships.
