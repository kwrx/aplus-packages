[![deploy](https://github.com/kwrx/aplus-packages/actions/workflows/build-and-deploy.yml/badge.svg)](https://github.com/kwrx/aplus-packages/actions/workflows/build-and-deploy.yml)
# Packages
 - `generic` system-base : *0.7*
 - `generic` system-cursors : *0.6*
 - `generic` system-fonts : *0.8*
 - `generic` system-images : *0.6*
 - `generic` system-keymaps : *0.6*
 - `x86_64` aplus : *latest*
 - `x86_64` aplus-browser : *1.10.0*
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

Pushing a tag matching `*.*.*` starts the [deploy](.github/workflows/build-and-deploy.yml) workflow, which builds the packages and publishes them as a GitHub release. The workflow can also be started manually from the Actions tab.

To build locally:

```sh
ci/prepare-and-build.sh x86_64 x86_64-linux-gnu
```
