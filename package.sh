#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ZIP="${1:-$ROOT/../hideSceneport_module.zip}"

if [[ ! -f "$ROOT/system/bin/hideport_loader" ]]; then
    echo "Missing executable: $ROOT/system/bin/hideport_loader" >&2
    echo "Run ./build.sh first." >&2
    exit 1
fi

if [[ ! -f "$ROOT/system/bin/hideport.bpf.o" ]]; then
    echo "Missing BPF object: $ROOT/system/bin/hideport.bpf.o" >&2
    echo "Run ./build.sh first." >&2
    exit 1
fi

(
    cd "$ROOT"
    rm -f "$ZIP"
    zip -r "$ZIP" \
        module.prop hideport.conf post-fs-data.sh service.sh hideport_start.sh hide_scene_port.sh customize.sh uninstall.sh service.d system \
        -x '*/.git/*'
)

echo "Wrote $ZIP"
