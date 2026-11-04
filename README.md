# Evergreen

*A community continuation of HMG Leafia Plus.*

> [!NOTE]
> **Evergreen is an unofficial community fork** of [HMG Leafia Plus](https://github.com/VysseCodes/HMG-Leafia-Plus) by VysseCodes, which was archived in favour of its successor, [HMG-API](https://github.com/VysseCodes/HMG-API), with community pull requests still unmerged. Evergreen keeps a working package available and merges those fixes. It isn't affiliated with or endorsed by the original author.
>
> **What Evergreen is for:** keeping Leafia's existing features working, not adding new ones. That means support for new firmware and cars that can use the existing builds, bug fixes, and keeping up with NEMESIS. New features are out of scope; for those, see [HMG-API](https://github.com/VysseCodes/HMG-API).
>
> **Already using Leafia?** Evergreen is the same package (`wireless.carplay.aa`), so it replaces Leafia rather than installing beside it. It also keeps the **Leafia kit** and its `LEAFIA-…` files and reports unchanged, so existing instructions and reports still work.
>
> **What's different from Leafia v1.0.5:**
> - Hyundai Ioniq 5 US firmware **260903** (2023 and 2024 SE): [upstream PR #179](https://github.com/VysseCodes/HMG-Leafia-Plus/pull/179) by gdonaldson1676. **Supported**: confirmed working on real cars, including with this fork's v1.1.0.
> - Hyundai Ioniq 5 US **2022** on firmware **260903**: same build as the 2023–2024 cars, since a 2022 owner's Leafia kit report shows identical stock files. **Supported**: v1.1.1 confirmed working on a 2022, turn-by-turn included.
> - Hyundai Ioniq 5 US **2024 special edition** (`NEEV23SE`) on firmware **260507**: the same files as the 2022–2023 cars on 260507, per an owner's Leafia kit report ([upstream #182](https://github.com/VysseCodes/HMG-Leafia-Plus/issues/182)). Not yet confirmed on the car with Evergreen.
> - Kia **Sportage** US on firmware **260507**: ported from an owner's Leafia kit ([#2](https://github.com/zpoon/gen5w-Evergreen/issues/2)). Its projection apps run the same code as the Ioniq 5 and EV6, so it gets the full build. **Supported**: confirmed working by the owner.
> - Package info in the NEMESIS 1.16 format, listing the firmware each car is supported on.
>
> If you'd rather use the original author's maintained project, see [HMG-API](https://github.com/VysseCodes/HMG-API).

Wireless **CarPlay** and **Android Auto** for Hyundai, Kia and Genesis **Gen5W** head units, installed through [NEMESIS](https://github.com/xwtk/hmg_nemesis), with turn-by-turn on the cluster and HUD on supported cars.

**Compatibility checker:** https://zpoon.github.io/gen5w-Evergreen/

## How it works

Firmware differs between models, regions and versions, so whole-file checksums rarely match across cars. Evergreen checks **only the bytes it changes**:

- **Recipes** (`recipes/*.recipe`) list the new bytes for each patch together with hashes of the region around it. They contain no bytes from Kia/Hyundai files.
- **`lpatch`** (`tools/lpatch/`) is a small static ARM tool that runs on the head unit. It patches only when every checked region matches its stock hash. A recipe therefore works on any firmware whose patched spots are identical, even when the rest of the file differs.
- **Native support is recognised:** some firmware already has a feature built in. For example, Korea's V039 build already accepts Wi-Fi CarPlay sessions and ships real AAC/Opus converters. Recipes record these files as `native`, so nothing is patched there.

| Part | What it does | How it is applied |
|---|---|---|
| Wireless projection | Enables the wireless CarPlay/AA feature flags for the unit's own region folder. Hotspot only: no Wi-Fi client, no extra Wi-Fi menu. | Feature files + config edits, all restored on uninstall |
| CarPlay Wi-Fi sessions | Lets `libCarPlayCore` accept Wi-Fi sessions | `carplay-core-wifi.recipe` |
| CarPlay wireless audio | Offers AAC (music) and Opus (Siri, calls, mic) over Wi-Fi, decoded with the unit's own codecs | `carplay-audio-formats.recipe`, `carplay-utils-converter.recipe` + `libev6aac.so` |
| Projection settings menu | On US/Canada units, Settings > Phone Projection keeps opening Device Connections (CarPlay split screen, connected phones), as on stock firmware; applied only where the Bluetooth settings app is the stock one the fix was made for | `patches/common/optional` (`HKMC_BtSettings`) |
| CarPlay Bluetooth bridge | Starts wireless CarPlay over Bluetooth/iAP2 | Rebuilt on the unit from its stock apps (`patches/<car>`) |
| Turn-by-turn | Projection navigation on the cluster and HUD | Rebuilt on the unit from its stock apps (`patches/<car>`). Uses only the standard cluster calls, so cars without a HUD are fine. The installer refuses if the firmware lacks any call it needs. |

Cars without a patch set yet get **basic mode**: only the wireless projection part, which gives wireless Android Auto on any Gen5W unit with a Wi-Fi module. The installer also saves a report so a full build can be made for that car.

## Install

1. Install [NEMESIS](https://github.com/xwtk/hmg_nemesis) **1.15 or newer** on the head unit (1.16 or newer recommended).
2. Check your car on the [compatibility page](https://zpoon.github.io/gen5w-Evergreen/) with the Leafia kit.
3. Download **Evergreen_Wireless_CarPlay_AA-<version>.zip** from the [latest release](../../releases/latest) (or build it yourself with `tools/build-package.sh`). Each release lists SHA256 checksums.
4. Unzip it onto the root of an empty exFAT or FAT32 USB drive (`NEMESIS.data` and `packages/`).
5. Car on (ideally in Ready, see the quirks below), plug in the drive and confirm the install. It takes a few minutes. While it runs, CarPlay, Android Auto, the navigation and Bluetooth settings are stopped so none of them restarts against half-changed files; they start again before the restart.
6. **When the head unit restarts, remove the drive.** Leaving it in can stop CarPlay or Android Auto from connecting the first time. The installer renames `NEMESIS.data` to `NEMESIS.data.installed` so it can't run again by accident.
7. **Uninstall** any time from NEMESIS Manager (My Packages → Uninstall), then restart: every file goes back to stock.

**Coming from the original Leafia (v1.0.5 or older)?** Evergreen uses the same package id, `wireless.carplay.aa`. Until updating in place has been tested on a car, **uninstall the old version in NEMESIS Manager and restart first**, then install this one as above. Uninstalling puts back your stock files, so the new install starts from a clean unit.

**Coming from HMG-API's wireless CarPlay/AA mod?** Turn that mod off first. Both change the same files.

**Optional: Wi-Fi client (testing).** By default the head unit's Wi-Fi only runs the hotspot that wireless CarPlay/Android Auto use. To also get the Wi-Fi menu and join a network (for example to reach ADB over your home Wi-Fi), put an empty file named `LEAFIA-WIFI-CLIENT` next to `NEMESIS.data` on the install drive. These units have one Wi-Fi radio, so whether a home network and wireless projection work at the same time is still being tested. Uninstalling turns it off again.

### Known quirks

- **USB drives and Android Auto.** On stock firmware a USB drive in the port makes the head unit try wired Android Auto, which blocks wireless Android Auto until the head unit restarts. Once Leafia is installed, Android Auto ignores USB drives and hubs. Before that (during the install, or on v1.0.4 and older), remove the drive once the head unit restarts.
- **Switching the car off and on doesn't restart the head unit.** It stays on until the driver's door opens or a timeout passes. For a real restart, switch off, open the driver's door and wait for the screen to go dark, or hold the head unit's power button for about 10 seconds.
- **Wireless CarPlay or Android Auto won't connect after an install** ("Phone not responding", or the phone joins the car's Wi-Fi and nothing happens): restart the head unit as above. If it still won't connect, pair again from scratch: on the phone forget the car in Android Auto (or CarPlay) settings, Bluetooth and Wi-Fi; on the car delete the phone.
- **An interrupted install** (car switched off, drive pulled): run the install again. Every run, finished or failed, ends with CarPlay, Android Auto, the navigation and Bluetooth settings running.
- **12 V battery during long sessions.** On an EV the 12 V battery is only charged while the car is in Ready. Installing and testing for a long time with the car on but not in Ready drains it; keep the car in Ready.
- **"Activate" or Kia Connect prompts in the navigation** come from the car's connected services, not from this package.
- **The Leafia kit only sees the last minute or so of the Android log.** When reporting a problem, run it right after the problem happens.

Something wrong? Open an issue with the [problem form](../../issues/new?template=problem.yml); it walks you through the Leafia kit.

## Packages

- **`packages/wireless-carplay-aa`:** the Wireless CarPlay/AA NEMESIS package source. Nothing modified is shipped: native libraries are patched on the head unit with `lpatch` recipes, and the projection apps are rebuilt on the unit from its own stock files with the patch sets in `patches/`.

## Supported head units

See the [compatibility page](https://zpoon.github.io/gen5w-Evergreen/). The data lives in `docs/data/compat.json` (cars with a build) and `docs/data/wanted.json` (Gen5W cars we'd like to add).

**Newest firmware only.** We support each car's newest head unit software for its region: currently **260507** in the US (and **260903** for the Ioniq 5) and **260206** in Canada. On older firmware the package installs wireless Android Auto only (basic mode) and asks you to update; use the free Hyundai, Kia or Genesis Navigation Updater, then install again.

**Navigation trims only.** Gen5W is the head unit in trims with built-in navigation. Trims without navigation have a different head unit ("Display Audio", for example "Display Audio Gen2V" on the Tucson) that NEMESIS and this package don't support.

**Korea:** reports from Korean head units are welcome, but we have yet to confirm a single working Korean car. Every Korean unit checked so far has had no Wi-Fi hardware, which wireless CarPlay and Android Auto need.

## The Leafia kit (run from a USB drive through NEMESIS)

One read-only kit (`kits/leafia`) covers checking a car, reporting a problem and porting to a new car. It comes in four sizes, built from the same source; each download carries a `LEAFIA-LEVEL` file that sets how much it collects:

| Download | Collects | Use it for |
|---|---|---|
| [leafia-kit-quick.zip](https://zpoon.github.io/gen5w-Evergreen/downloads/leafia-kit-quick.zip) | `public/` only | checking a car (seconds) |
| [leafia-kit.zip](https://zpoon.github.io/gen5w-Evergreen/downloads/leafia-kit.zip) | + `private/logs` (latest crash records) and `private/keys` | reporting a problem |
| [leafia-kit-port.zip](https://zpoon.github.io/gen5w-Evergreen/downloads/leafia-kit-port.zip) | + `private/stock` (~90 MB) | adding a new car |
| [leafia-kit-full.zip](https://zpoon.github.io/gen5w-Evergreen/downloads/leafia-kit-full.zip) | + every crash record | deep debugging, when asked |

It writes `LEAFIA/` on the drive:

| Folder | Contents | Share |
|---|---|---|
| `public/` | `LEAFIA-REPORT.txt` (firmware ids, checksums, patch checks: drop it on the compatibility page), `summary.txt` (NEMESIS and package state, hotspot, crash record names), our install logs | Safe to post on an issue |
| `private/logs/` | Android and kernel logs, NEMESIS logs, crash dumps, network state; can include phone names or Bluetooth addresses | **Privately, only when asked** |
| `private/stock/` | Stock framework, CarPlay/projection apps and libraries (Hyundai/Kia files), used to port the package | **Privately, only when asked** |
| `private/keys/` | Firmware key files | **Privately, only when asked; never posted** |

### Data policy

- **Public** (issues, this repo): the kit's `public/` folder, recipes, checksums, compatibility data.
- **Private only** (never committed here): the kit's `private/` folder (logs, stock firmware files, firmware key files) and full modified app builds. The repo holds only patch sets that rebuild them from a unit's own stock files.
- **Never collected:** anything under `/data` except NEMESIS's own folder, crash logs and the hotspot's address leases — so no accounts, paired phones or Wi-Fi passwords — the vehicle security partition (modem and connected-service certificates), the VIN and serial numbers.

## Contributing

Evergreen is maintenance only: it keeps the existing features working rather than adding new ones. The most useful help is **reports from new cars and firmware**, **real-car test results**, and **bug reports and fixes**. Ideas for new features are better suited to [HMG-API](https://github.com/VysseCodes/HMG-API), the original author's active project.

Reports from new cars, real-car tests and code are all welcome: see [CONTRIBUTING.md](CONTRIBUTING.md) for setup, building, testing on the mock head unit, adding a car, and the project rules. Security issues: [SECURITY.md](SECURITY.md).

## Credits and licences

- Evergreen is a fork of HMG Leafia Plus, created by [VysseCodes](https://github.com/VysseCodes). Evergreen is maintained by [zpoon](https://github.com/zpoon). If the original work helped you, you can support its author through [GitHub Sponsors](https://github.com/sponsors/VysseCodes) or [Ko-fi](https://ko-fi.com/vyssecodes).
- Merged into Evergreen: Hyundai Ioniq 5 US 260903 by [gdonaldson1676](https://github.com/gdonaldson1676) (upstream #179).
- Evergreen, like HMG Leafia Plus, is GPL-3.0 (see `LICENSE`).
- It runs through [NEMESIS](https://github.com/xwtk/hmg_nemesis) by xwtk, which is AGPL-3.0. Parts derived from NEMESIS packages are listed in `NOTICE.md` and stay under their original licence.
- Thanks to [W-Floyd](https://github.com/W-Floyd) for their help with this project.
- Not affiliated with Hyundai, Kia, Genesis, Apple or Google. Modifying your head unit is at your own risk.
