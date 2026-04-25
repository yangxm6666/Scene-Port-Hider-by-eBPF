#!/system/bin/sh
MODDIR=${0%/*}

sh "$MODDIR/hideport_start.sh" service >/dev/null 2>&1 &
sh "$MODDIR/service.d/hide_scene_port.sh" >/dev/null 2>&1 &
