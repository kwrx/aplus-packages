[![deploy](https://github.com/kwrx/aplus-packages/actions/workflows/build-and-deploy.yml/badge.svg)](https://github.com/kwrx/aplus-packages/actions/workflows/build-and-deploy.yml)
# Packages
 - `generic` system-base : *0.7*
 - `generic` system-cursors : *0.6*
 - `generic` system-fonts : *0.8*
 - `generic` system-images : *0.6*
 - `generic` system-keymaps : *0.6*
 - `x86_64` aplus : *latest*
 - `x86_64` aplus-odyssey : *2.34.6*
 - `x86_64` bash : *5.1*
 - `x86_64` binutils : *2.38*
 - `x86_64` bochs : *3.1*
 - `x86_64` busybox : *1.35.0*
 - `x86_64` bzip2 : *1.0.8*
 - `x86_64` cairo : *1.18.4*
 - `x86_64` curl : *8.22.0*
 - `x86_64` dash : *0.5.11.5*
 - `x86_64` doom : *1.0.0*
 - `x86_64` expat : *2.8.4*
 - `x86_64` ffmpeg : *9.0.2*
 - `x86_64` fontconfig : *2.17.1*
 - `x86_64` freetype : *2.12.1*
 - `x86_64` gcc : *12.2.0*
 - `x86_64` git : *2.56.0*
 - `x86_64` glib : *2.88.4*
 - `x86_64` gmp : *6.2.1*
 - `x86_64` harfbuzz : *8.5.0*
 - `x86_64` icu : *78.3*
 - `x86_64` isl : *0.24*
 - `x86_64` libffi : *3.8.0*
 - `x86_64` libghostty-vt : *1.0.1*
 - `x86_64` libjpeg-turbo : *3.2.0*
 - `x86_64` libpng : *1.6.37*
 - `x86_64` libpsl : *0.21.5*
 - `x86_64` libressl : *4.3.2*
 - `x86_64` libtsm : *4.8.0*
 - `x86_64` libwebp : *1.2.4*
 - `x86_64` libxml2 : *2.15.4*
 - `x86_64` libxslt : *1.1.45*
 - `x86_64` lua : *5.5.1*
 - `x86_64` make : *4.4*
 - `x86_64` mesa : *22.3.0*
 - `x86_64` mpc : *1.2.1*
 - `x86_64` mpfr : *4.1.0*
 - `x86_64` mupdf : *1.28.5-source*
 - `x86_64` nano : *9.2*
 - `x86_64` ncurses : *6.6*
 - `x86_64` nesemu : *1.0.0*
 - `x86_64` netsurf-all : *3.11*
 - `x86_64` openssh : *10.6p2*
 - `x86_64` pcre2 : *10.49*
 - `x86_64` pixman : *0.46.4*
 - `x86_64` pkgconf : *1.1.0*
 - `x86_64` Python : *3.15.1*
 - `x86_64` readline : *8.3*
 - `x86_64` sqlite : *autoconf-3540100*
 - `x86_64` tzdata : *2026f*
 - `x86_64` util-linux : *2.42.4*
 - `x86_64` xz : *5.8.4*
 - `x86_64` zlib : *1.3.2*
 - `x86_64` zstd : *1.5.7*

# Build

Every tag matching `*.*.*` triggers the [deploy](.github/workflows/build-and-deploy.yml) workflow, which runs `ci/prepare-and-build.sh` and publishes a GitHub release with every package archive, the `index` and the `buildinfo` file.

Builds are incremental: only packages whose inputs changed since the latest release are rebuilt, everything else is reused from that release.

## Build keys

`ci/pack.py` computes a key for each package as the sha256 of:

 - every file in the recipe directory (`package.yml`, patches, scripts, assets);
 - the resolved source URLs, plus the current remote `HEAD` commit for `.git` sources;
 - the keys of all its dependencies, so a change propagates to every dependent package;
 - a global salt made of the target, toolchain version, zig version, `requirements.txt` and the optional `APLUS_CACHE_SALT` repository variable.

Keys are published in the `buildinfo` release asset, one `name:key:sha256` line per package.

## Reusing prebuilt packages

At build time `pack.py` downloads `buildinfo` from `releases/latest/download`, which still points to the previous release while the new one is being built. For each package:

 - if its key matches, the archive is downloaded from the previous release and its checksum verified, without building;
 - otherwise it is rebuilt. Reused dependencies that are needed by a rebuilt package have their sources fetched and their archive extracted into `__out`, so `$PACKAGE_*/__out` paths keep working.

A recipe can set `restorable: false` when its dependents need more than its `__out` directory (for example `aplus`, whose source tree is used by other packages). Such a package is rebuilt whenever one of its dependents is rebuilt.

If the previous release has no `buildinfo`, every package is built.

## Forcing a full rebuild

 - run the workflow manually with the `full_rebuild` input enabled;
 - or change the `APLUS_CACHE_SALT` repository variable, which invalidates every key.

Changes to `ci/pack.py` itself do not change the keys, so use one of the options above when they affect the produced archives.

## Building locally

```sh
ci/prepare-and-build.sh x86_64 x86_64-linux-gnu
```

Outside GitHub Actions every package is built from scratch. Set `APLUS_PREBUILT_URL` to the download URL of a release (for example `https://github.com/kwrx/aplus-packages/releases/latest/download`) to reuse its packages.
