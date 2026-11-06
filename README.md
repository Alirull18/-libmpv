# libmpv (LGPL) build for KayroTv

Builds `libmpv-2.dll` for 64-bit Windows with GitHub Actions, for use by KayroTv. The goal is a player library whose licence and source are documented, and that we can rebuild ourselves instead of depending on someone else's releases.

## What it does

`.github/workflows/libmpv-lgpl.yml` (manual run only):

1. Checks out [shinchiro/mpv-winbuild-cmake](https://github.com/shinchiro/mpv-winbuild-cmake), the build system for mpv and its libraries, at the commit you give (blank = latest).
2. Applies `compile-lgpl-libmpv.patch`, which disables the GPL-only and non-free parts of FFmpeg and mpv, and `patch/*.patch`.
3. Builds with `build.sh` (GCC toolchain, x86_64, libmpv only).
4. **Fails the build** if the libmpv it produced contains FFmpeg's `--enable-gpl` or `--enable-nonfree` in its recorded configure line.
5. Writes `BUILD-INFO.txt` (toolchain, mpv and FFmpeg commits, hashes, link to the run), `ffmpeg-configure-flags.txt`, and `SOURCES.txt` plus `kayro-libmpv-sources.tar.xz.part-NN`, the source of every tree it built from.
6. Optionally publishes all of that as a GitHub release. Releases are never deleted automatically.

## How to run it

Actions tab, **libmpv-lgpl**, **Run workflow**. Tick *publish* to create a release. A cold build downloads and compiles the GCC toolchain and about sixty libraries, so expect it to take hours; the job limit is six hours.

## Licence position (read this before shipping)

- The build scripts here are MIT (see `LICENSE`, from [zhongfly/mpv-winbuild](https://github.com/zhongfly/mpv-winbuild), commit `37b83557ec1cb08a241defc77f60cb151f7b314c`).
- The output is meant to be an **LGPL** libmpv with a statically linked LGPL FFmpeg (the upstream project describes its `mpv-dev-lgpl` package as LGPLv2.1+ for libmpv and LGPLv3 for the FFmpeg inside it). The upstream author adds: "I'm not a lawyer and can't guarantee that I've disabled all LGPL-incompatible packages, use at your own risk." The same applies here.
- The flag check in step 4 catches FFmpeg's own switches only. It does not prove that every other bundled library is LGPL-compatible. Someone responsible for the licence must read `SOURCES.txt` and the licence files in the source archive before a public release.
- Ship `libmpv-2.dll` as a separate file next to the application so that users can replace it, and include the LGPL notices and a link to the matching release in the application.

## Not frozen

The build follows the latest commit of every package unless you pin the toolchain commit, and the toolchain pulls the latest of each library. A rebuild next month will not give identical output. What is stable is each **release**: its binary, `BUILD-INFO.txt`, hashes and source archive are kept together.

## Credits

Build system: shinchiro/mpv-winbuild-cmake. LGPL patch and workflow design: zhongfly/mpv-winbuild (MIT).
