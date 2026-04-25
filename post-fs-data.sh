#!/system/bin/sh
MODDIR=${0%/*}

sh "$MODDIR/hideport_start.sh" post-fs-data >/dev/null 2>&1 &
