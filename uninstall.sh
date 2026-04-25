#!/system/bin/sh

PIDFILE="/dev/hideport_loader.pid"

if [ -f "$PIDFILE" ]; then
    PID="$(cat "$PIDFILE" 2>/dev/null)"
    if [ -n "$PID" ]; then
        kill "$PID" 2>/dev/null
    fi
    rm -f "$PIDFILE"
fi

rm -rf /dev/hideport_loader.lock
