## 0.4.1 (2026-10-18)

### Fix

- update git source URLs to use HTTPS instead of SSH

## 0.4.0 (2026-10-18)

### Feat

- add doom package with desktop entry and build configuration

## 0.3.1 (2026-10-17)

### Fix

- add zlib dependency and update CFLAGS in package.yml
- update toolchain version to 0.2.0 in prepare-and-build.sh
- correct symbolic link command in fix-alternatives.sh
- update build commands to use dynamic default target; create applications directory in pre-install script; enhance strip-binaries script for safer execution

## 0.3.0 (2026-09-20)

### Feat

- add netsurf browser and pkgconf package with aplus support

### Fix

- disable HTTPD feature in Busybox configuration
- remove input argument for pack.py in prepare-and-build script
- add libjpeg-turbo to dependencies and update CFLAGS in aplus package; enable Duktape support in netsurf-all package
- update PATH_MAX to 4096 in package configurations and patches
- update package list in README and improve package search logic in report script
- restrict package search to current directory in install-local script
- update CFLAGS and CPPFLAGS to optimize build settings

## 0.2.1 (2026-09-16)

### Fix

- update prepare-and-build.sh to use correct toolchain version and pass architecture to build script

## 0.2.0 (2026-09-16)

### Feat

- add commitizen configuration and update deployment trigger to use tags

## 0.1.0 (2026-09-16)

### Feat

- update package configurations and add missing files for system base

### Fix

- bad filename on tar extraction
- ssl error on wget download
