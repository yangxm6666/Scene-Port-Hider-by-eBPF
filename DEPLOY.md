# Deployment Model

There are two practical ways to publish this module.

## Recommended: self-build from a connected device

This is the safest path for unknown phones and kernels. The user needs WSL/Linux,
ADB, root access on the phone, and `/sys/kernel/btf/vmlinux`.

```sh
git clone https://github.com/YOUR_NAME/hideport_module.git
cd hideport_module
bash tools/build_for_connected_device.sh
```

The script:

- pulls `/sys/kernel/btf/vmlinux` with `adb pull`;
- generates `src/vmlinux.h` with `bpftool`;
- downloads Android NDK r25c if needed;
- builds Android arm64 `libz.a`, `libelf.a`, and `libbpf.a`;
- builds `hideport_loader` and `hideport.bpf.o`;
- writes `../hideSceneport_module.zip`.

The user installs the zip in KernelSU Manager and reboots.

## Fork and build with GitHub Actions

This works when users do not want to install the Android NDK or build libbpf
locally. GitHub Actions cannot access their phone, so the user must commit their
target kernel BTF to the fork.

User flow:

```sh
git clone https://github.com/USER/hideport_module.git
cd hideport_module
mkdir -p btf
adb shell su -c 'cp /sys/kernel/btf/vmlinux /data/local/tmp/vmlinux.btf && chmod 0644 /data/local/tmp/vmlinux.btf'
adb pull /data/local/tmp/vmlinux.btf ./btf/vmlinux.btf
adb shell su -c 'rm -f /data/local/tmp/vmlinux.btf'
git add btf/vmlinux.btf
git commit -m "Add target kernel BTF"
git push
```

Then open the fork on GitHub:

```text
Actions -> Build KernelSU module -> Run workflow
```

The finished `hideSceneport_module.zip` appears as a workflow artifact.

If users do not want to commit `vmlinux.btf`, they can generate and commit
`src/vmlinux.h` instead. The workflow accepts either file.

## Prebuilt releases

You can publish prebuilt zips, but label them by device and kernel:

```text
hideSceneport_OP5D0DL1_kernel-5.10.x_2026-04-25.zip
```

Prebuilt packages are only expected to work on matching or very similar kernels.
For different devices, ask users to run the self-build script or send their
`/sys/kernel/btf/vmlinux` file so you can build a matching package.

## Why users should not hand-build bpftool/deps

The manual route is fragile on Windows/WSL because binary BTF can be corrupted by
shell redirection, Android NDK static linking has a few ARM64/Bionic quirks, and
libbpf/libelf cross-compilation needs Android-specific flags. Keep those details
inside the script.
