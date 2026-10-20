CC     = $(APLUS_HOST)-gcc
AR     = $(APLUS_HOST)-ar
STRIP  = $(APLUS_HOST)-strip

prefix = /usr

CFLAGS  = -O2 $(addprefix -I,$(addsuffix /include,$(APLUS_DEPS)))
LDFLAGS = -static $(addprefix -L,$(addsuffix /lib,$(APLUS_DEPS)))

NO_PERL      = YesPlease
NO_PYTHON    = YesPlease
NO_TCLTK     = YesPlease
NO_GETTEXT   = YesPlease
NO_REGEX     = YesPlease

CURL_CONFIG  = false
CURL_CFLAGS  =
CURL_LDFLAGS = -lcurl -lssl -lcrypto -lz

HAVE_ALLOCA_H         = YesPlease
HAVE_PATHS_H          = YesPlease
HAVE_DEV_TTY          = YesPlease
HAVE_CLOCK_GETTIME    = YesPlease
HAVE_CLOCK_MONOTONIC  = YesPlease
HAVE_GETDELIM         = YesPlease
HAVE_SYSINFO          = YesPlease
CSPRNG_METHOD         = getrandom
FREAD_READS_DIRECTORIES = UnfortunatelyYes

SKIP_DASHED_BUILT_INS = YesPlease
INSTALL_STRIP         = -s --strip-program=$(STRIP)
