# Patch sets

One folder per car, plus `common/`. The head unit rebuilds the modified projection apps from its own stock files with these (see `packages/wireless-carplay-aa/scripts/build.sh`), so no modified app is shipped.

| Folder | Car | Firmware |
|---|---|---|
| `ev6/` | Kia EV6, US (`CVEV.USA.*`) | 260507 |
| `ev6_ca/` | Kia EV6, Canada (`CVEV.CAN.*`): same code as the US EV6, so its manifest uses the `ev6/` patches on Canada's own APKs | 260206 |
| `neev/` | Hyundai Ioniq 5, US (`NEEV.USA.*`, `NEEV23.USA.*`) | 260507 |
| `neev23_260903/` | Hyundai Ioniq 5, US (`NEEV23.USA.*`, `NEEV23SE.USA.*`, and 2022 `NEEV.USA.*` with the same stock files): ported from `neev/` | 260903 |
| `neev_ca/` | Hyundai Ioniq 5, Canada (`NEEV.CAN.*`): its Android Auto library differs from the US one, so it carries its own library delta | 260206 |
| `nq5/` | Kia Sportage, US (`NQ5.USA.*`): ported with `tools/port.py` from an owner's kit, with the Ioniq 5 as reference; every class is identical, only the APK/odex wrappers differ | 260507 |
| `dl3hev/` | Kia K5 Hybrid, Korea: kept, not in `cars` (no Korean unit has shown Wi-Fi hardware) | 260902 |
| `neev_kr/` | Hyundai Ioniq 5, Korea: kept, not in `cars` (as above) | 260902 |
| `universal/` | For cars with no set of their own: patches keyed to the **code inside** each stock `.odex` (`lpatch odexdex`) rather than the `.odex` file, so they fit every car whose apps run that code, whatever its framework. `manifest`: `<part> app <App> <code md5> <patch> <result dex md5>` and `<part> file <library> <stock md5> <patch> <result md5>`. Made with `tools/mkuniversal.py <stock dir> <set>`; the installer (`scripts/universal.sh`) uses them only if every app and the library match, and then writes the car's own set to `patches/auto/` on the unit | any |
| `common/` | `libautoreceiver_infobank.so` for every car with the US stock library (a car with a different one has its own delta in its folder); `optional`: fixes applied wherever the stock file matches | |

`cars` maps a firmware product id prefix (`ro.build.product`) to a folder and a car name. The installer reads it, so adding a car needs no script changes.

## Files

- `<App>.tbt.lpd`: rebuilds the turn-by-turn version of the app's code from the stock `<App>.odex`.
- `<App>.bridge.lpd`: rebuilds the CarPlay-bridge version (turn-by-turn included).
- `stock`: md5 of each stock file this car must have (`<file name> <md5>`).
- `manifest`: one line per output: `<part> <app|file> <name> <patch> <md5 of the result>`.

An `.lpd` holds the md5 of the exact stock file it needs and of the result. `lpatch delta` writes nothing unless both match.

## Adding a car

Have the owner run the **port** Leafia kit (`leafia-kit-port.zip`) on the new car and send its `LEAFIA/private` folder privately (`stock/` holds the projection apps and the framework), then:

```
tools/port.py --variant <name> --prefix <product prefix> --name "<car name>" --new-stock <dir> --new-fw <LEAFIA/private/stock/framework> --ref-stock <EV6 stock dir> --ref-fw <EV6 framework> --ref-builds <builds dir> --out-builds <dir>
```

`<dir>` holds the new car's `app/<App>.apk`, `app/<App>.odex` and `lib/libautoreceiver_infobank.so`.

It compares the new car's apps with the EV6's class by class:

- Classes that are identical, or that differ but carry none of our changes, are taken as they are.
- Classes that differ and carry our changes are merged automatically when the difference is only renamed members (obfuscation shifts between firmwares), or when our change applies cleanly as a 3-way patch.
- Anything else stops the port and is listed for a person to merge.

Every result is then checked: each reference inside the app must resolve, and every system call must exist in the new car's framework. If all checks pass, it writes `patches/<name>/` and adds the car to `cars`. The full builds in `--out-builds` stay private.

Ported this way, the Ioniq 5 comes out byte for byte identical to its hand-made set, and the K5 Hybrid class for class identical.

## The universal build (`universal/`)

A car's own set rebuilds each app from that car's exact stock `.odex`. An `.odex` is the app's optimised dex plus a header holding checksums of the framework it was made against, so cars whose apps run the same code have byte-identical dex inside different `.odex` files (the Ioniq 5 and Sportage on US 260507, for example). `lpatch odexdex` writes that dex out, and the universal patches rebuild the modified app from it.

On a unit whose product id isn't in `cars`, the installer takes the code md5 of each app the universal manifest names, and the library's md5. If every one has a line, it builds those apps (`odexdex` → `delta` → `zipadd` with the unit's own APK) and writes `patches/auto/{stock,manifest,product}`, this unit's own checksums in the usual set format, so the parts install and uninstall as for any car. One mismatch and nothing is generated: basic mode, as before.

After a new port, add its code to the universal list too: `tools/mkuniversal.py <stock dir> <set>` (lines for code already listed are replaced). EV builds (`+ev`) stay per car.

## Optional fixes (`common/optional`)

Fixes that aren't tied to one car's projection apps, listed in `common/optional` in the manifest's line format. The head unit applies each one only when its stock file is the exact one the `.lpd` was made from; otherwise it logs a skip and the install carries on.

- `HKMC_BtSettings.menu.<stock md5 prefix>.lpd` (part `5_menu`), one per stock version of the Bluetooth settings app: with our wireless features on, Settings > Phone Projection would open the wireless projection page, which has no CarPlay split-screen option and lists no phones paired through our bridge. On US/Canada units this keeps it on Device Connections, as on stock US firmware. Make one for a car with `tools/mkmenu.py <stock dir>` (it adds the line here); the unit uses the first line whose stock file it has.

## Making a set by hand

Needs the car's stock files (`app/<name>.apk`, `app/<name>.odex`, `lib/libautoreceiver_infobank.so`), the modified builds in the `2_tbt/<files>` and `3_bridge/<files>` layout, the host `lpatch` (`tools/lpatch/build.sh`) and `pip install --require-hashes -r tools/requirements.txt`:

```
tools/mkpatches.py <ev6|neev|dl3hev> <stock dir> <builds dir> patches
```

The installer's stock checksums (`comp/2_tbt`) and expected app checksums (`comp/3_bridge`) must match the new set.
