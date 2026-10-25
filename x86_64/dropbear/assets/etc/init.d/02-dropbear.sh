#!/bin/sh

EXEC_NAME="dropbear"
EXEC_DESC="SSH server"

case "$1" in
    start)
        if command -v $EXEC_NAME >/dev/null 2>&1; then
            echo "init.d: starting $EXEC_DESC..."
            mkdir -p /etc/dropbear
            $EXEC_NAME -R -p 22 &
        else
            echo "init.d: $EXEC_NAME not found, skipping $EXEC_DESC startup."
        fi
        ;;
    stop)
        echo "init.d: stopping $EXEC_DESC..."
        pkill $EXEC_NAME
        ;;
    restart)
        "$0" stop
        "$0" start
        ;;
    *)
        echo "usage: $0 {start|stop|restart}"
        exit 1
        ;;
esac
