# Build

## Prereqs

| Tool | Check | Note |
|---|---|---|
| `just` | `which just` | task runner |
| `podman` | `which podman` | required for image + VM builds |
| `yq` | `which yq` | reads pinned digests from `image-versions.yaml` |
| `git` | `which git` | required |

## Fast validation

```bash
just check && just lint
```

- `just check` validates Just syntax, including the ujust recipes in `system_files/usr/share/ublue-os/just/`.
- `just lint` runs shellcheck on all `*.sh` files.

## Core builds

`just build [image] [tag] [nvidia] [hwe] [kernel_pin]`

| Goal | Command | Typical time |
|---|---|---|
| Main image (HWE kernel) | `just build` | 45-90 min |
| Nvidia | `just build bluefin-lts-kde-nvidia lts-hwe 1 1` | 45-90 min |
| CentOS kernel (no HWE) | `just build bluefin-lts-kde lts 0 0` | 45-90 min |

**Never cancel builds.** Use 120+ minute timeouts.

## How the build is layered

1. `build_scripts/overrides/base/` installs the kernel (from the akmods images), EPEL, codecs, and KDE Plasma.
2. Files are copied in this order, with later copies winning: `ghcr.io/ublue-os/brew`, then the `shared` half of `ghcr.io/projectbluefin/common`, then this repo's `system_files/`.
3. `build_scripts/[0-9][0-9]-*.sh` run in order: workarounds, packages, gaming packages, post-install, services, image info.
4. `system_files_overrides/x86_64` and `build_scripts/overrides/x86_64` apply, then the `nvidia` overrides when `ENABLE_NVIDIA=1`.
5. `build_scripts/cleanup.sh` runs last.

## Repo layout

| Path | Use |
|---|---|
| `build_scripts/` | package install + build logic |
| `build_scripts/scripts/dnf-install-available` | best-effort installer for optional packages |
| `system_files/` | base system config (gaming sysctl/udev, Flatpak preinstalls, ujust recipes) |
| `system_files_overrides/` | arch / Nvidia overrides |
| `Containerfile` | main image definition |
| `image.toml` | bootc-image-builder config for VM images |

## VM / disk artifacts

| Command | Purpose |
|---|---|
| `just build-qcow2` | convert existing container image to QCOW2 |
| `just rebuild-qcow2` | build image, then QCOW2 |
| `just run-vm-qcow2` | boot QCOW2; web console on `http://localhost:8006` |

Never run VMs in CI; KVM/graphics are required.
