# Changelog

## v0.1.2 (2026-11-20)

The exe reports the version it was actually built as, and a release is published only after its build succeeded.

* **Launcher:** the file and product version of `Gow2HD-Windows.exe` (Windows Properties, and the embedded manifest)
  is generated from `LAUNCHER_VERSION` in `src/config.h` at build time instead of being written by hand, so the
  binary can no longer report an older version than the tag it came from, and bumping the version is one edit.
* **Release:** `build.cmd` writes that version resource before `windres` runs, and the release workflow builds, checks
  and scans the launcher first and creates the release only afterwards, so a failed build no longer leaves a
  published release without `Gow2HD-Windows.exe`. The version checks are unchanged and still run before anything is
  built, so a version that cannot be released fails in seconds.

## v0.1.1 (2026-11-20)

Install folders and checkouts can be renamed or moved without confusing the launcher.

* **Paths:** the build records the game folder, the `.pkg` and the runtime config's `vfs_root` relative to the install
  folder (and `build_info.json` relative to the project) when they lie inside it, and absolute only when they do not.
  Renaming the install folder or the checkout no longer breaks a finished build or a rebuild.
* **Launcher:** the build state (`game`, licence, ELF and the built exe) is stored relative to the install folder and
  resolved on every read, and the install itself is found again after a rename: the launcher recognises the folder it
  runs from and corrects the path it remembered. When it runs from somewhere else (download and run), it offers a
  folder picker instead of showing the setup page as if the build had been deleted; answering No forgets the old
  folder, so the next start is a plain first run rather than the same question again.
* **Reports:** the catalog and marker reports no longer embed the absolute paths of the machine that generated them.

## v0.1.0 (2026-10-11)

First public release.

* **Gow2HD-Windows.exe** launcher: finds your game folder or PSN package (`.pkg`) and your licence (`.rap`), downloads
  pinned, SHA-256-checked tools (embeddable Python, llvm-mingw, FFmpeg), builds the port on your PC with `build.py`
  and starts the game. Remove build, update check, Quiver support.
* **Build:** one command (`build.py`) from the game folder or the PSN package; no game data in the repository.
* **Graphics:** Direct3D 12 renderer, resolution scale 1x-4x, borderless/windowed (F11), the game's Full Frame
  option, no haze or dark line at the screen edges at higher resolution scales, Colossus fixes.
* **Performance:** async GPU command processing, faster SPU jobs and guest memory access; own frame limiter up to
  1000 fps with a 162 fps cap for G-Sync/FreeSync at 165 Hz, even frame pacing below the cap (Kratos no longer snaps
  between poses).
* **Port Settings** (F1): frame-rate cap, display mode, resolution scale, fps counter (F10), checkpoints.
* **Checkpoints:** F6 saves the game's latest checkpoint with a picture, F1 lists and loads them in game.
* **Movies:** all 45 prerendered movies, full length, picture/sound sync, SELECT pause, hold-START skip; a movie can
  no longer stall the game.
* **Audio:** native SCREAM mixer; a recursive-lock bug in the runtime that could leave a sound-stream thread blocked
  for good (music silent while other sounds play) is fixed.
* **Fixes:** the first trophy unlock no longer crashes; music keeps playing after a checkpoint load from the pause
  menu; start-up swap-chain hang recovery.
* Known issues: see [README.md](README.md#known-issues).
