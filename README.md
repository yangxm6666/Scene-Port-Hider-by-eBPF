# eBPF Port Hider KernelSU Module

This module hides bind-based probes for TCP ports `8788` and `8765` while
allowing the target app UID, root, and system to bind them normally.

## Important implementation note

The original draft used `tracepoint/syscalls/sys_enter_bind` together with
`bpf_override_return()`. Many Android kernels do not expose that helper, so this
implementation uses kprobes and rewrites non-whitelisted bind probes for the
protected port to port `0`. The kernel then chooses an ephemeral free port, so
bind-based scanners see a successful bind.

## Configure

Edit `hideport.conf` before packaging if needed:

```sh
PKG=com.omarea.vtools
PORTS="8788 8765"
ENABLE_EBPF=1
WAIT_FOR_PROCESS=0
```

`hideport_start.sh` only owns the eBPF bind-probe hider. The Scene connect-probe
hider is packaged separately as `service.d/hide_scene_port.sh`, matching the
standalone service.d mode.

## Build

For users building their own package from a connected phone:

```sh
bash tools/build_for_connected_device.sh
```

For users building from a fork with GitHub Actions, commit `btf/vmlinux.btf`
from the target phone and run the `Build KernelSU module` workflow. See
`DEPLOY.md`.

For manual builds on Linux or WSL with Android NDK, bpftool, clang, and a static
ARM64 libbpf/libelf/zlib setup:

```sh
adb shell su -c "bpftool btf dump file /sys/kernel/btf/vmlinux format c" > src/vmlinux.h
export ANDROID_NDK=/path/to/android-ndk-r25c
./build_deps_android.sh
export LIBBPF_SRC="$PWD/deps/android-arm64"
export LIBBPF_HEADERS="$LIBBPF_SRC/include"
export LIBBPF_LIBDIR="$LIBBPF_SRC/lib"
./build.sh
./package.sh
```

When building from WSL under `/mnt/c` or `/mnt/d`, `chmod` can fail because the
directory is backed by a Windows filesystem. The module installer sets runtime
permissions on-device, so a chmod warning after the files are built is harmless.

For Android Studio, see `ANDROID_STUDIO.md`. The included `CMakeLists.txt`
builds `hideport_loader`, generates `hideport.bpf.o`, and copies both outputs to
`system/bin`.

Install `hideSceneport_module.zip` from KernelSU Manager and reboot.

See `DEPLOY.md` for GitHub release and self-build distribution notes.

## Verify on device

```sh
su -c 'cat /data/adb/modules/hideSceneport/hideport.log'
su -c 'cat /data/adb/modules/hideSceneport/hide_scene.log'
su -c 'bpftool prog list | grep hideport'
```

If every attach attempt fails, inspect `hideport.log` and the device kallsyms for
the actual bind syscall symbol name.
