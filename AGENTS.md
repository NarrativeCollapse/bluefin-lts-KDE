# Bluefin LTS KDE — Agent Quick Reference

KDE Plasma gaming image on CentOS Stream 10 (bootc), derived from Bluefin LTS with Bazzite-style gaming features. See `README.md` for what the image contains.

**Lazy-load skills — read only what the task needs.**

| Task | Load |
|---|---|
| Local build, validation, packages | `docs/skills/build.md` |

## Always-On Rules

- **NEVER cancel builds** — 45–90 min, set 120+ min timeout
- **NEVER re-enable ISO builds** — Anaconda is broken on the CentOS Stream base
- Only packages available for CentOS Stream 10 / EPEL 10 can be used. Fedora-only repos (RPM Fusion, Terra, Fedora COPRs) do not apply.
- Install packages the image cannot work without with plain `dnf -y install`, so a missing package fails the build. Use `build_scripts/scripts/dnf-install-available` only for nice-to-haves.
- Steam is x86_64-only: do not add arm64 builds back.

## Quick Commands

```bash
just check && just lint                          # validate before every commit
just build                                       # full build (120+ min timeout)
just build bluefin-lts-kde-nvidia lts-hwe 1 1    # Nvidia variant
```
