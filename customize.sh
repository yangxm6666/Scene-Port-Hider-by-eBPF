#!/system/bin/sh

SKIPUNZIP=0

on_install() {
    ui_print "- Installing eBPF Port Hider"
    ui_print "- Edit hideport.conf if your package or ports differ"
}

set_permissions() {
    set_perm_recursive "$MODPATH" 0 0 0755 0644
    set_perm "$MODPATH/post-fs-data.sh" 0 0 0755
    set_perm "$MODPATH/service.sh" 0 0 0755
    set_perm "$MODPATH/hideport_start.sh" 0 0 0755
    set_perm "$MODPATH/hide_scene_port.sh" 0 0 0755
    set_perm "$MODPATH/service.d/hide_scene_port.sh" 0 0 0755
    set_perm "$MODPATH/system/bin/hideport_loader" 0 0 0755
}
