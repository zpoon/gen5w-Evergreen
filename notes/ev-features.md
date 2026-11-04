# Initiative: EV features in Evergreen (from egmp-aa-ev-feat)

Status: **built, waiting for a car test**. The EV GPM and library for the Ioniq 5 US 260507 (`neev` set, so the 2022, 2023 and 2024 SE on 260507) were built from the maintainer's stock files on 2026-11-04 and are in `patches/neev/manifest` as `+ev` lines; package-version 1.2.0. Off-car: the mock head unit installs the EV build by default and the plain one with `EVERGREEN-NO-EV`, and both uninstall to byte-identical stock (mksh). Every other car builds as before.

## Goal

One package that does everything, so cars don't end up with several packages
patching the same files. Today [egmp-aa-ev-feat](https://github.com/willemcvu/egmp-aa-ev-feat)
by willemcvu is a separate package, `aa.ev.model`. It stacks on Leafia v1.0.5's
modified Android Auto files: the GPM app and `libautoreceiver_infobank.so`. That
makes it break whenever the base changes. Its author has stopped working on it
and has given permission to roll it into another project. Evergreen takes it
over as a built-in part.

What it adds for Android Auto with Google Maps:
- **EV routing:** a vehicle energy model with the battery's live energy, so Maps
  plans charging stops and shows arrival %.
- **Learned capacity:** the battery's usable capacity, learned from the BMS.
- **Cold-weather losses** in the model.
- **Calibrated charge times.**
- **Automatic battery preconditioning** when the next stop is a fast charger.
- **EV logging**, copied to a USB drive.

## Decisions

- **On by default** on supported cars. An empty `EVERGREEN-NO-EV` file next to
  `NEMESIS.data` on the install drive installs the plain turn-by-turn build
  instead. Preconditioning keeps the car's own *battery conditioning* setting as
  its off switch, as it does today.
- **First release: Hyundai Ioniq 5 US on 260507 only.** That's what
  egmp-aa-ev-feat is proven on, and the maintainer's car can supply the stock
  files and the testing. 260903 comes next (see "Later").
- **Scope:** the README's "maintenance only" statement changes to also cover
  *consolidating community features into one package, so they don't conflict*.
  This happens in the same release as the feature.

## Before any code

1. **Permission: done.** willemcvu agreed publicly on 2026-11-03 ("anyone
   taking it and doing whatever with it"). It's quoted, dated and linked in
   `NOTICE.md`. They said they'll add a licence to their repo. When they do, if
   it's GPL-3.0-compatible, link it from `NOTICE.md` too. They'd like to keep
   improving the energy model through PRs, which Evergreen should welcome.
2. **Bring the history across: done** (branch `ev-import`, all 33 of
   willemcvu's commits kept). Used
   `git subtree add --prefix=ev https://github.com/willemcvu/egmp-aa-ev-feat main`,
   so willemcvu's commits and authorship stay in Evergreen's history. Credit it
   in `NOTICE.md` and the README.
3. **Review the vehicle commands: done**, in `notes/ev-vehicle-commands.md`.
   The three preconditioning commands are approved as they are. Before
   release, the reads need the same firmware gate as the writes, the VIN read
   has to go, and the log-offload service needs renaming.

## Design

### Where it plugs in

Evergreen already rebuilds GPM and the Android Auto library on the unit, from
stock files (part `2_tbt`). Stacking a second patch on top of that would bring
back exactly the problem this initiative is meant to solve. Instead, a supported
car gets **one GPM build that already includes turn-by-turn and EV**:

- **New GPM delta:** `patches/neev/HKMC_GPM.ev.lpd` rebuilds the TBT+EV GPM
  straight from the stock `HKMC_GPM.odex`, like the existing `.tbt.lpd` and
  `.bridge.lpd` files.
- **New library delta:** `patches/common/libautoreceiver_infobank.ev.lpd` turns
  the stock US library into the TBT+EV library. egmp-aa-ev-feat's library patch
  adds a tail branch to the turn-by-turn library, so the new delta starts from
  stock and includes both.
- **Manifest lines (done):** an EV build is a manifest line whose part ends in
  `+ev`, e.g. `2_tbt+ev app HKMC_GPM neev/HKMC_GPM.ev.lpd <md5>`. `scripts/build.sh`
  uses it in place of the plain line for the same part and file, unless
  `EVERGREEN-NO-EV` is on the install drive. A car with no `+ev` lines gets the
  plain build, as today. Tested by `tools/test-ev-select.sh`; the mock head unit
  takes `MOCK_NO_EV=1`.
- **Compatibility page:** its `built` lists already accept several md5s per
  file, so both variants count as "already installed".

### Logging service

**Done.** egmp-aa-ev-feat's `evlog-offload.sh` is now `svc/evlog-offload.sh`, a `[service.0]` in Evergreen's
`NEMESIS.data` (`type=application,service`), tested by `tools/test-evlog-offload.sh`. It copies logs to a drive with an
`egmp-aa-ev-logs/` folder; that name stays, since existing instructions use it.
It exits straight away on a car without the EV build. The GPM code writes the
logs itself and keeps at most 100 MB.

### Conflicts and migration

- **Refuse while the old add-on is installed (done).** `aa.ev.model` is in `LEGACY` in
  `scripts/common.sh`, so the installer refuses to run until it's gone, and says why. Both
  patch the same two files.
- **Migration steps for current users:**
  1. Uninstall `aa.ev.model`.
  2. Uninstall Leafia.
  3. Restart.
  4. Install Evergreen.

  The EV logs written so far live under `/data` and aren't touched. Confirm
  where `EvDriveLog` writes them, and keep the path.

### Package

- The package ID stays `wireless.carplay.aa`.
- `package-version` 1.2.0 for the first EV release.
- `os=` is unchanged. EV is a per-car extra inside the same package.

## Building (private inputs)

The EV GPM is built from a car's stock GPM, which can't live in the repo. Done for
the Ioniq 5 US 260507 on 2026-11-04; to redo it (or for another car):

1. **Stock files:** the owner runs the **port kit** and sends `LEAFIA/private/stock`
   privately. Check it against `patches/<set>/stock` first.
2. **Toolchain**, from official sources only:
   - smali/baksmali 2.5.2: Ubuntu's `libsmali-java` (`apt install libsmali-java`).
   - Android 4.4 `android.jar` and `d8`: Google's `platforms;android-19`
     (`android-19_r04.zip`, SHA-1 `2ff20d89e68f2f5390981342e009db5a2d456aaa`) and
     `build-tools;34.0.0` (`build-tools_r34-linux.zip`, SHA-1
     `d6d58e0c6925a9e4d9a541e84cd1f405c2f9d2a9`) from dl.google.com, as listed in
     `repository2-1.xml`. `~/tools/env.sh` sets `ANDROID_HOME` to them.
   - Python: `capstone==5.0.1` (plus `setuptools<80` on Python 3.12+, for its
     `distutils` import) and Evergreen's `tools/requirements.txt` (bsdiff4).
   - Evergreen's host `lpatch` (`cc -DHOST -O2 -o lpatch-host tools/lpatch/lpatch.c`).
3. **Base:** rebuild Evergreen's turn-by-turn files from stock with `lpatch-host
   delta` (`patches/<set>/HKMC_GPM.tbt.lpd`, `patches/common/libautoreceiver_infobank.tbt.lpd`)
   and check them against the manifest (GPM APK `0308224b…`, library `c08410a8…`
   on 260507, the same base egmp-aa-ev-feat was built on).
4. **Library:** `ev/tools/patch_library.py <tbt lib> <out>` (result `37cbe6bf…`).
5. **GPM:** `baksmali d --api 18` the turn-by-turn dex into
   `ev/private/car-current-leafia105/smali-gpm`, then `sh ev/gpm-ev/build.sh`,
   `ev/tools/patch_gpm_smali.py`, `smali a -j 1 --api 18 -o <dex> ev/build/gpm-smali`,
   and `lpatch-host zipadd <stock APK> <dex> <apk>` (dex `79eacf25…`, APK `b9a641e9…`).
   Everything under `ev/private`, `ev/build`, `ev/dist` and `ev/gpm-ev/build` is
   git-ignored; delete it afterwards.
6. **Deltas:** `tools/mkdelta.py <stock odex> <EV dex> patches/<set>/HKMC_GPM.ev.lpd`
   and `tools/mkdelta.py <stock lib> <EV lib> patches/common/libautoreceiver_infobank.ev.lpd`;
   round-trip both with `lpatch-host delta`, then add the `+ev` manifest lines and
   run `tools/compat-built.py`.
7. **Checks done on 2026-11-04:** two clean builds gave the same dex and APK;
   `dexdump` reads the dex (DEX 035, 824 classes = 792 + 32 EV); no `getVIN` or
   `vin_model` in it; the car's framework (deodexed with `baksmali x -a 18`) has
   every interface the EV code looks up by name, with the numbers egmp-aa-ev-feat
   verified (HEV 3, DATC 0x29/6, BCM 1, IBCMListener 0x11, hscan 0xb/0xd6), and
   its `automotive*.odex` and `com.hkmc.ext.hcan.odex` hashes match `Precond`'s
   and `EvCar`'s checks. Mock install with and without `EVERGREEN-NO-EV` passed.

## Testing

1. **Host tests (in CI, job "Test EV Features"):** egmp-aa-ev-feat's Java host
   tests (`ev/gpm-ev/test`, plus `TxTest` for the lookup by name),
   `ev/tools/test_evlog.sh`, and Evergreen's `tools/test-ev-select.sh` and
   `tools/test-evlog-offload.sh` under sh and mksh.
2. **Mock head unit:** Evergreen's `tools/mock/install-test.sh`, run with the
   maintainer's stock tree, with and without `EVERGREEN-NO-EV`. The uninstall
   must leave `/system` byte-identical.
3. **On the maintainer's car** (2023 Ioniq 5 SEL, 260507):
   - Maps shows arrival % and plans charging stops.
   - Preconditioning comes on for a route to a fast charger under 60 minutes
     away, and is cancelled when the route ends.
   - Logs copy to a drive.
   - Turn-by-turn and CarPlay still work.
   - Uninstall restores stock.
4. **Migration:** Leafia v1.0.5 plus `aa.ev.model` → refused with a clear
   message → after uninstalling both, Evergreen installs.

## Later

- **Ioniq 5 260903:** rebuild the EV smali edits onto the 260903 GPM, using a
  260903 owner's port kit. egmp-aa-ev-feat's `patch_gpm_smali.py` works from
  the turn-by-turn smali tree, so this is a rebuild, not new code.
  **Re-verify the HEV/BCM transaction numbers on that firmware first.** Better
  still, look them up by name, the way Battery Watchdog's `TxnResolver` does,
  instead of hard-coding them.
- **Kia EV6:** needs its own energy model (`build_model_template.py` has a
  generic path), a check that its data sources match, and its own testing.
- **Model improvements:** egmp-aa-ev-feat's roadmap (log analysis, a model that
  adjusts itself) moves to Evergreen issues.
