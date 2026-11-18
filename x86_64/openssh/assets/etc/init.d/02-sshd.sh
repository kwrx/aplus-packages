#!/bin/sh

EXEC_NAME="sshd"
EXEC_DESC="SSH server"
EXEC_ARGS="-D -e"

case "$1" in
    start|restart)
        mkdir -p /var/empty /var/run
        ssh-keygen -A >/dev/null || exit 1
        ;;
esac

. "$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)/00-init.sh"
