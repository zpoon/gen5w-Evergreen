# Initiative: EV features in Evergreen (from egmp-aa-ev-feat)

Status: **planned**. Nothing is merged yet. This note is the plan.

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

1. **Put the permission on record.** Ask willemcvu to add a `LICENSE` file
   (GPL-3.0, to match Evergreen) to egmp-aa-ev-feat, or to post the permission
   in a public issue there. The repo has no licence today. Only its bundled
   `lpatch`, which came from Leafia, is GPL. A public record keeps Evergreen's
   provenance clear for anyone who reuses it later.
2. **Bring the history across.** Use
   `git subtree add --prefix=ev https://github.com/willemcvu/egmp-aa-ev-feat main`,
   so willemcvu's commits and authorship stay in Evergreen's history. Credit it
   in `NOTICE.md` and the README.
3. **Review the vehicle commands.** This is required by the rules in
   `CLAUDE.md`. Preconditioning calls the stock HEV service's binder
   transactions **3, 62, 65 and 66** (`setBattCondEvStation`,
   `setBattCondRouteDis`, `setBattCondRemainTime`) and BCM transaction **109**,
   **by number**. They're verified on Ioniq 5 US 260507 only. Write down what
   each one does, what values it sends, and how a request gets cancelled (route
   ended, session teardown, stale journal on the next start).

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
- **Manifest lines:** the car's manifest gets lines tagged for an EV variant,
  for example part `2_tbt`, variant `ev`. `scripts/build.sh` picks the EV lines
  unless `EVERGREEN-NO-EV` is present. A car with no EV lines gets the plain
  build, as today.
- **Compatibility page:** its `built` lists already accept several md5s per
  file, so both variants count as "already installed".

### Logging service

egmp-aa-ev-feat's `evlog-offload.sh` becomes a `[service.0]` in Evergreen's
`NEMESIS.data` (`type=application,service`). It copies logs to a drive with an
`egmp-aa-ev-logs/` folder; that name stays, since existing instructions use it.
It exits straight away on a car without the EV build. The GPM code writes the
logs itself and keeps at most 100 MB.

### Conflicts and migration

- **Refuse while the old add-on is installed.** Add `aa.ev.model` to `LEGACY` in
  `scripts/common.sh`, so the installer refuses to run until it's gone. Both
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

The EV GPM is built from a car's stock GPM, which can't live in the repo.

1. **Stock files:** the maintainer runs the **port kit** on his own Ioniq 5
   (US, 260507) and keeps `LEAFIA/private/stock` privately.
2. **Toolchain:** Android SDK, smali/baksmali (`-a 18` and `--api 18 -j 1`, as
   in `CLAUDE.md`), protoc, and Python with `bsdiff4` and `capstone`.
3. **Build:** egmp-aa-ev-feat's `tools/build_all.sh` steps, with the base being
   Evergreen's turn-by-turn GPM. On 260507 that's byte-identical to Leafia
   v1.0.5's, which is what egmp-aa-ev-feat was built against.
4. **Make the deltas** with `tools/mkdelta.py`, from the stock files to the
   results, and add the manifest lines with the result md5s.
5. **Check:** the build must be deterministic. A second build gives the same
   md5s.

## Testing

1. **Host tests:** egmp-aa-ev-feat's Java host tests (`gpm-ev/test`) and
   `tools/test_evlog.sh`, added to CI.
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
