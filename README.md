# Bluefin LTS KDE

A KDE Plasma gaming desktop on CentOS Stream 10, built as a [bootc](https://containers.github.io/bootc/) image.

It starts from [Bluefin LTS](https://github.com/ublue-os/bluefin-lts), strips it down, replaces GNOME with KDE Plasma, and adds the gaming features of [Bazzite](https://github.com/ublue-os/bazzite) that work on an enterprise Linux base.

> **Status: experimental and not yet built.** Package names for KDE and the gaming tools on EPEL 10 have not been checked against a real build, so expect the first CI runs to need fixes.

## What's in it

- **Desktop:** KDE Plasma (Wayland only, since CentOS Stream 10 has no Xorg server) with SDDM, from EPEL (maintained by the Fedora KDE SIG). It has no GNOME and no GNOME extension submodules.
- **Kernel:** the newer Fedora CoreOS kernel ("HWE") instead of the CentOS one, plus these kernel modules from Universal Blue's akmods:
  - xone (Xbox wireless adapter)
  - openrazer
  - v4l2loopback
  - Framework laptop drivers
- **Game launchers:** Steam, Lutris, Heroic and ProtonPlus are installed from Flathub on first boot, along with Firefox, Flatseal and the Bazaar app store.
- **Gaming tweaks (from Bazzite):**
  - split-lock mitigation off, and a high `vm.max_map_count`
  - higher memlock and inotify limits
  - BBR TCP congestion control
  - kyber/bfq I/O schedulers
  - ntsync autoload when the kernel has it
  - restart of KDE's login screen (SDDM) after a GPU reset
- **Controllers:** Valve's Steam Input and Steam VR udev rules, plus gamemode, gamescope and MangoHud on the host where EPEL has them.
- **ujust:**
  - `ujust install-gaming-layers` adds the MangoHud, gamescope and OBS capture Vulkan layers for Flatpak games.
  - `ujust gaming-status` shows which tweaks are active.
- **Kept from Bluefin LTS:** Homebrew, Tailscale, distrobox, automatic updates (uupd), Flathub, codecs, and the shared Universal Blue setup hooks from [projectbluefin/common](https://github.com/projectbluefin/common).

### Images

| Image | Tag | Contents |
|---|---|---|
| `ghcr.io/narrativecollapse/bluefin-lts-kde` | `lts-hwe` | AMD and Intel graphics |
| `ghcr.io/narrativecollapse/bluefin-lts-kde-nvidia` | `lts-hwe` | Adds the Nvidia open kernel driver |

Images are x86_64 only, since Steam doesn't run on ARM. Builds from branches other than `main` get a `-testing` suffix, for example `lts-hwe-testing`.

### Differences from Bazzite

Bazzite is built on Fedora, and some of its features depend on Fedora-only packages or its own kernel. On CentOS Stream these are missing:

- Steam Deck / handheld "game mode" (gamescope session, Handheld Daemon)
- Bazzite's patched kernel and Valve's patches
- Steam, Lutris and gamescope as system packages (here, the launchers are Flatpaks)

## Removed from Bluefin LTS

- GNOME, its extensions, and the GNOME 50 build
- The DX (developer tools) and GDX (CUDA / AI) variants. The Nvidia driver lives on as the `-nvidia` image.
- ZFS
- ARM64 builds
- The CentOS-kernel (non-HWE) image in CI. `just build bluefin-lts-kde lts 0 0` still builds it locally.
- Upstream's `main` → `lts` promotion, release and changelog workflows. Here `main` is the publishing branch.
- Bluefin's branding, wallpapers and GNOME settings (the `bluefin` half of projectbluefin/common), and its "countme" usage ping.

## Building

```bash
just build                                       # bluefin-lts-kde:lts, HWE kernel
just build bluefin-lts-kde-nvidia lts-hwe 1 1    # Nvidia variant
just check && just lint                          # quick validation
```

Builds take 45–90 minutes and need `podman`, `just` and `yq`.

## Setup before publishing

The CI workflows push to `ghcr.io/<owner>` and sign images with cosign. Before the first publish:

1. Generate a signing key with `cosign generate-key-pair` (leave the password empty).
2. Add the private key as the `SIGNING_SECRET` Actions secret.
3. Replace `cosign.pub` in this repo with your public key. The current file is the upstream Universal Blue key.
4. Add a container signature policy for `ghcr.io/<owner>` to the image, so that `bootc` can verify updates to the signed image ref in `/usr/share/ublue-os/image-info.json`. Until then, switch to the image with `bootc switch` without signature enforcement.

## Switching to it

From an existing bootc system (for example Bluefin LTS):

```bash
sudo bootc switch ghcr.io/narrativecollapse/bluefin-lts-kde:lts-hwe
```

ISO builds are not provided, since Anaconda does not work on the CentOS Stream bootc base.

## Credits

Built on the work of the [Universal Blue](https://universal-blue.org), [Bluefin](https://projectbluefin.io) and [Bazzite](https://bazzite.gg) projects (Apache-2.0). Controller rules are from [ValveSoftware/steam-devices](https://github.com/ValveSoftware/steam-devices) (MIT).
