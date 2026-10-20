## 0.8.0 (2026-10-20)

### Feat

- add user-agent header to urllib requests in pack.py
- add pre-install script and shell configuration files
- add init script and package configuration for dropbear SSH server

### Fix

- update source URL and remove unnecessary setup step in libwebp package

## 0.7.1 (2026-10-19)

### Fix

- remove redundant cleanup of sdk and temporary build directory
- escape characters in build configuration for mesa package

## 0.7.0 (2026-10-19)

### Feat

- add package configuration and patch for xz 5.8.4
- add package configuration and patch for SQLite autoconf 3540100
- add package configuration and patch for nano 9.2
- add package configuration and patch for GNU Make 4.4
- add Lua package configuration file
- add metadata generation and indexing for packages
- add readline package and patch for aplus compatibility
- add ncurses package and patch for aplus compatibility

### Fix

- correct order of arguments in tar command for packaging
- update .gitignore to include /index and ensure /sdk/ is ignored
- include index file in deployment artifacts
- update bash package configuration for improved compatibility and features
- update CONFIG_CLEAR setting in busybox configuration
- update environment variables and user configurations
- update MuPDF configuration to support images in user.make

## 0.6.1 (2026-10-18)

### Fix

- streamline musl library setup in configure-stdcxx.sh
- add CC variable to build environment in package.yml for doom and nesemu

## 0.6.0 (2026-10-18)

### Feat

- add user.make and package.yml for MuPDF configuration and build setup

## 0.5.0 (2026-10-18)

### Feat

- add nesemu package with build configuration and dependencies

### Fix

- update CFLAGS to include SRCDIR for nesemu package build

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
