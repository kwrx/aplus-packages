#!/bin/sh

EXEC_NAME="dropbear"
EXEC_DESC="SSH server"
EXEC_ARGS="-F -R -p 22"

. "$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)/00-init.sh"
