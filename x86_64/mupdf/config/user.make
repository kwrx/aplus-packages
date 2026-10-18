# MuPDF for aplus: PDF and images, static, cross-built with the aplus toolchain.

CROSS_COMPILE ?= x86_64-aplus-

OS := aplus
prefix ?= /usr

CC := $(CROSS_COMPILE)gcc
CXX := $(CROSS_COMPILE)g++
AR := $(CROSS_COMPILE)ar
LD := $(CROSS_COMPILE)ld
RANLIB := $(CROSS_COMPILE)ranlib

# Every format and optional library except PDF and images.
mujs := no
brotli := no
html := no
xps := no
svg := no
extract := no
threading := no

# Host pkg-config probes in Makerules that would otherwise leak into the build.
HAVE_GLUT := no
HAVE_X11 := no
HAVE_LIBCRYPTO := no
HAVE_OBJCOPY := yes

# CJK from Droid Sans Fallback Full instead of Source Han Serif.
tofu_cjk_lang := yes

# freetype, libjpeg and zlib from the environment set by package.yml.
# Makerules reassigns SYS_* after this file, so the values are pinned with override.
USE_SYSTEM_FREETYPE := yes
USE_SYSTEM_LIBJPEG := yes
USE_SYSTEM_ZLIB := yes

override SYS_FREETYPE_CFLAGS := $(SYS_FREETYPE_CFLAGS)
override SYS_FREETYPE_LIBS := $(SYS_FREETYPE_LIBS)
override SYS_LIBJPEG_CFLAGS := $(SYS_LIBJPEG_CFLAGS)
override SYS_LIBJPEG_LIBS := $(SYS_LIBJPEG_LIBS)
override SYS_ZLIB_CFLAGS := $(SYS_ZLIB_CFLAGS)
override SYS_ZLIB_LIBS := $(SYS_ZLIB_LIBS)

CFLAGS += -DFZ_ENABLE_CBZ=0
CFLAGS += -DFZ_ENABLE_ODT_OUTPUT=0 -DFZ_ENABLE_OCR_OUTPUT=0
CFLAGS += -DFZ_ENABLE_HYPHEN=0
