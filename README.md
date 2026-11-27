<p align="center"><img src="docs/assets/evergreen-icon.svg" alt="Evergreen icon: a pine tree sending out wireless waves" width="160"></p>

# Evergreen

**Wireless CarPlay and Android Auto for Hyundai, Kia and Genesis cars with the Gen5W navigation head unit.** Get in, start the car, and your phone connects on its own, with no cable. Directions show up on the instrument cluster and the head-up display, the same way the car's own navigation does.

Evergreen installs from a USB drive through [NEMESIS](https://github.com/xwtk/hmg_nemesis) and can be uninstalled at any time, which puts every file back exactly as it came from the factory.

**Will it work on my car?** Check on the [compatibility page](https://zpoon.github.io/gen5w-Evergreen/).

## Features

### Wireless CarPlay and Android Auto
- **No cable needed.** Your phone connects over the car's own Wi-Fi hotspot, with Bluetooth handling the setup.
- **Full-quality CarPlay audio.** Music streams in high quality, and Siri, calls and the microphone work over Wi-Fi too.
- **Phone Projection settings stay where you expect.** Settings > Phone Projection still opens the usual screen, with CarPlay split screen and your connected phones.

### Directions on the cluster and HUD
- **Turn-by-turn arrows and distances** from Apple Maps, Google Maps, Waze and other navigation apps, on the instrument cluster and the head-up display (on cars that have one).
- **Lane guidance** with CarPlay: the lanes you should be in, shown as you approach the turn. *Not working in 1.3.0; a fix is in testing for 1.3.1.*
- **Speed limits and camera warnings keep working.** Signs from the car's own map stay on the cluster while your phone is guiding you.
- **The car's own navigation stays out of the way.** Its lanes and turns don't mix with your phone's while the phone is guiding.
- **Switching apps is clean.** Going from Apple Maps to Waze (or back) clears the old route from the cluster before the new one appears.
- **The car's own navigation comes back normally** once you stop using phone directions.

### For EV drivers (Android Auto with Google Maps)
On supported EVs (so far the Hyundai Ioniq 5, US and Canada, on 260507 and 260903, and the Kia EV6, US on 260507 and Canada on 260206, *in testing*), Evergreen includes the EV features from [egmp-aa-ev-feat](https://github.com/willemcvu/egmp-aa-ev-feat):
- **Charging stops planned from your real battery level.** Google Maps uses the car's live battery data to plan charging stops and show your arrival percentage.
- **Battery preconditioning on the way to a fast charger**, when the car's own *battery conditioning* setting is on.
- **EV drive logs** that you can copy to a USB drive (create a folder named `egmp-aa-ev-logs` on the drive).

### For EV drivers (CarPlay with Apple Maps) *(in testing)*
On the same cars, Evergreen includes [egmp-carplay-ev-routing](https://github.com/isaacwisdom/egmp-carplay-ev-routing): the head unit tells the iPhone the car is electric, with its charging connectors, and keeps sending the live battery level and range, so **Apple Maps can plan charging stops and show your battery level on arrival**. If Apple Maps doesn't offer EV routing after installing, remove the car under CarPlay on the iPhone (Settings > General > CarPlay) and connect again.

Don't want the EV features (Android Auto and CarPlay)? Put an empty file named `EVERGREEN-NO-EV` next to `NEMESIS.data` on the install drive.

### Fixes for problems in the stock software
- **USB drives no longer block wireless Android Auto.** On stock software, plugging in a USB drive can lock out wireless Android Auto until the head unit restarts.
- **No more CarPlay crash when the phone reconnects** after a dropped connection.
- **Opens the ports wireless projection needs** on cars whose firmware blocks them on the hotspot (Ioniq 6).
- **The CarPlay picture recovers on its own** if it freezes.
- **The "first connection" CarPlay notice** only shows the first time, not on every drive.
- **Faster first start** after installing.
- **A warning when the head unit's Wi-Fi is on,** since that can make CarPlay and Android Auto drop (see below).

### Safe to try
- **Checks before it changes anything.** If your car's software isn't one Evergreen knows, it doesn't patch it.
- **Full uninstall.** Removing Evergreen restores every file to the factory version.
- **Works on more cars than it was built for.** If your car runs the same software as a supported car, Evergreen recognises it and installs the full version. Otherwise it installs **basic mode** (wireless Android Auto only) and saves a report so support for your car can be added.

## Supported cars

On the newest head unit software:

| Car | Software |
|---|---|
| Kia EV6 (US) | 260507 |
| Hyundai Ioniq 5 (US, 2022–2024, including the 2024 SE) | 260507 or 260903 |
| Hyundai Ioniq 6 (US) | 260903 |
| Kia Sportage and Sportage Hybrid (US) | 260507 |

Being tested:

| Car | Software |
|---|---|
| Hyundai Palisade (US, 2025) | 260903 |
| Hyundai Ioniq 5 (Canada) | 260903 or 260206 |
| Kia EV6 (Canada) | 260206 |
| Kia EV6 (Korea) | 260902 |

See the [compatibility page](https://zpoon.github.io/gen5w-Evergreen/) for the full, current list.

**Update your head unit first.** Evergreen supports only each car's newest software for its region. On older software it installs basic mode and asks you to update. Updates are free with the Hyundai, Kia or Genesis Navigation Updater.

**Navigation trims only.** Cars without built-in navigation have a different head unit ("Display Audio") that isn't supported.

**Korea:** the Kia EV6 on 260902 is the first Korean head unit with working Wi-Fi, and it's in testing ([#11](https://github.com/zpoon/gen5w-Evergreen/issues/11)); Android Auto turn-by-turn on the cluster isn't in it yet. Other Korean units checked so far (Kia K5 Hybrid, Hyundai Ioniq 5) had no Wi-Fi hardware. Reports from Korean cars are welcome.

## Install

1. Install [NEMESIS](https://github.com/xwtk/hmg_nemesis) **1.15 or newer** on the head unit (1.16 or newer recommended).
2. Check your car on the [compatibility page](https://zpoon.github.io/gen5w-Evergreen/) with the [quick kit](#the-kit).
3. Download **Evergreen_Wireless_CarPlay_AA-<version>.zip** from the [latest release](../../releases/latest).
4. Unzip it onto an empty USB drive formatted exFAT or FAT32, so `NEMESIS.data` and `packages/` are at the top level.
5. With the car on (ideally in Ready), plug in the drive and confirm the install. It takes a few minutes, and CarPlay, Android Auto and the navigation pause while it runs.
6. **When the head unit restarts, remove the drive.**

**Updating:** with NEMESIS 1.16 or newer, install the new version over the old one.
**Uninstalling:** in NEMESIS Manager go to My Packages → Uninstall, then restart.

**Coming from HMG Leafia Plus?** Evergreen replaces it. Uninstall Leafia in NEMESIS Manager and restart first.
**Using HMG-API's wireless CarPlay/AA mod?** Turn that mod off first, since both change the same files.

## Tips and known issues

- **CarPlay or Android Auto drops every minute or two? Turn the head unit's Wi-Fi off.** The car's Wi-Fi can run either the hotspot your phone uses or a connection to another network, but doing both at once disrupts the hotspot. Turn Wi-Fi off in the head unit's Wi-Fi settings (or NEMESIS Manager's WiFi button), forget any saved networks, and restart. If you use NEMESIS Manager's Store, turn Wi-Fi on only while parked.
- **Won't connect after installing?** Restart the head unit. If that doesn't help, pair again from scratch: on the phone, forget the car in CarPlay/Android Auto, Bluetooth and Wi-Fi; on the car, delete the phone.
- **Turning the car off and on doesn't restart the head unit.** For a real restart, switch off, open the driver's door and wait for the screen to go dark, or hold the power button for about 10 seconds.
- **Install interrupted?** Just run it again.
- **Watch the 12 V battery on an EV.** It only charges while the car is in Ready, so keep the car in Ready for long installs or tests.
- **"Activate" or Kia Connect prompts** come from the car's connected services, not from Evergreen.

> [!CAUTION]
> **Don't use NEMESIS's Settings → Use Telematics Internet.** It uses the car's built-in modem and SIM, which the manufacturer provides only for its own services. Using them for anything else may break their terms and could get the car's connected services suspended.

**Optional: Wi-Fi client (testing).** To join a home network from the head unit as well, put an empty file named `LEAFIA-WIFI-CLIENT` next to `NEMESIS.data` on the install drive. Because of the Wi-Fi issue above, this may cause drops while driving.

Having a problem? Open an issue with the [problem form](../../issues/new?template=problem.yml). It walks you through running the kit.

## The kit

The kit is a separate download that you run from a USB drive through NEMESIS. It changes nothing on the car; it only reads. Use it to check whether your car is supported, to report a problem, or to help add support for a new car. Its files still carry the old `leafia` name so that older reports keep working.

| Download | Use it for |
|---|---|
| [leafia-kit-quick.zip](https://zpoon.github.io/gen5w-Evergreen/downloads/leafia-kit-quick.zip) | Checking your car (takes seconds) |
| [leafia-kit.zip](https://zpoon.github.io/gen5w-Evergreen/downloads/leafia-kit.zip) | Reporting a problem |
| [leafia-kit-port.zip](https://zpoon.github.io/gen5w-Evergreen/downloads/leafia-kit-port.zip) | Adding a new car (~90 MB) |
| [leafia-kit-full.zip](https://zpoon.github.io/gen5w-Evergreen/downloads/leafia-kit-full.zip) | Deep debugging, when asked |

The kit writes a `LEAFIA` folder to the drive with two parts:
- **`public/`** is safe to post. Drop `LEAFIA-REPORT.txt` on the [compatibility page](https://zpoon.github.io/gen5w-Evergreen/) or attach the folder to an issue.
- **`private/`** holds logs, factory software files and firmware key files. Share it **privately, and only when a maintainer asks**. Never post it publicly.

The kit never collects your accounts, paired phones, Wi-Fi passwords, VIN or serial numbers.

## How it works

Evergreen never ships modified Hyundai or Kia files. Instead, it changes your head unit's own files on the car, and only after checking that each spot it changes is exactly as expected. That's why a single package can cover many cars and why uninstalling can restore the originals byte for byte. For the details, building, testing and adding a car, see [CONTRIBUTING.md](CONTRIBUTING.md).

## Contributing

The most useful help is **reports from new cars**, **test results from real cars**, and **bug reports and fixes**. See [CONTRIBUTING.md](CONTRIBUTING.md) to get started, and [SECURITY.md](SECURITY.md) for security issues.

## Credits and licences

- Evergreen is maintained by [zpoon](https://github.com/zpoon). It started as a fork of [HMG Leafia Plus](https://github.com/VysseCodes/HMG-Leafia-Plus) by [VysseCodes](https://github.com/VysseCodes) (now archived). If that work helped you, you can support its author through [GitHub Sponsors](https://github.com/sponsors/VysseCodes) or [Ko-fi](https://ko-fi.com/vyssecodes).
- Hyundai Ioniq 5 US 260903 support by [gdonaldson1676](https://github.com/gdonaldson1676).
- EV features: [egmp-aa-ev-feat](https://github.com/willemcvu/egmp-aa-ev-feat) by [willemcvu](https://github.com/willemcvu), included with their permission (see `NOTICE.md`).
- CarPlay EV routing: [egmp-carplay-ev-routing](https://github.com/isaacwisdom/egmp-carplay-ev-routing) by [Isaac Wisdom](https://github.com/isaacwisdom) (GPL-3.0-or-later), with the identification code from HMG-API's wireless mod (see `NOTICE.md`).
- Runs through [NEMESIS](https://github.com/xwtk/hmg_nemesis) by xwtk (AGPL-3.0). Parts derived from NEMESIS packages are listed in `NOTICE.md` and keep their original licence.
- Thanks to [W-Floyd](https://github.com/W-Floyd) for their help with this project.
- Evergreen is GPL-3.0 (see `LICENSE`).
- Not affiliated with Hyundai, Kia, Genesis, Apple or Google. Modifying your head unit is at your own risk.
