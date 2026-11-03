# Notices

## Evergreen

Evergreen is a community fork of HMG Leafia Plus by VysseCodes (https://github.com/VysseCodes/HMG-Leafia-Plus), GPL-3.0, maintained by zpoon. Everything below describes HMG Leafia Plus as it was forked; Evergreen keeps the same licences.

## egmp-aa-ev-feat (EV features, permission)

egmp-aa-ev-feat by willemcvu (https://github.com/willemcvu/egmp-aa-ev-feat): Google Maps EV routing, battery preconditioning and EV logging for Android Auto. At the time of writing, that repository has no licence file. Its author gave permission publicly, in the NEMESIS community Discord on 2026-11-03 (13:06 UTC), in reply to taking it over:

> "Yes, go for it. I do need to add a license but have absolutely no problems with anyone taking it and doing whatever with it. I'd like to continue improving the energy consumption models but can do that easily as a PR on someone else's repo too eventually."

Message link (visible to members of that server): https://discord.com/channels/1074629698379841567/1558908831143297125/1567163151449989332

On that basis, code taken from egmp-aa-ev-feat into Evergreen is distributed under Evergreen's licence, GPL-3.0, with credit to willemcvu. Its bundled `lpatch` came from HMG Leafia Plus and is GPL-3.0 already.

## NEMESIS

HMG Leafia Plus packages install and run through **NEMESIS** by xwtk:
https://github.com/xwtk/hmg_nemesis. NEMESIS is licensed under the GNU Affero General Public License v3.0.

The Wireless CarPlay/AA package builds on these NEMESIS community packages. Their scripts and builds remain under the AGPL-3.0:

- **Enable Wireless Features** (`wireless.projection`). The HMG Leafia Plus version is a slimmed copy of its scripts: hotspot-only, plus a fix that finds the region folder via `ro.mobis.targetdir`.
- **Turn-by-Turn Guidance for Phone Projection** (`projection.tbt`). Used as-is; its app builds are the base for the CarPlay bridge builds.

## Original HMG Leafia Plus work (GPL-3.0)

`lpatch`, the recipes and recipe tooling, the Leafia kit, the compatibility site, the CarPlay Bluetooth bridge, the CarPlay Wi-Fi/audio patches and the `libev6aac.so` audio converter.

## Community contributions

- **CarPlay turn-by-turn maneuver fix** (DiPO route-guidance parser wrote maneuver indexes into a copy of the index array, so every maneuver read as -1 and CarPlay guidance never reached the cluster). Contributed by [Isaac Wisdom](https://github.com/isaacwisdom); applied to the EV6, Ioniq 5 and K5 builds.

## Thanks

- [W-Floyd](https://github.com/W-Floyd), for their help with this project.

## Third-party code used at runtime

The audio converter loads the head unit's own `libstagefright_soft_aacdec.so` (Fraunhofer FDK AAC) and `libopus.so` at runtime. Nothing from them is bundled.
