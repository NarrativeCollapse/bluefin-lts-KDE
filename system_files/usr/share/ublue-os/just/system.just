# Install MangoHud, gamescope and OBS game-capture layers for Flatpak games
[group('Gaming')]
install-gaming-layers:
    #!/usr/bin/bash
    set -euo pipefail
    if ! flatpak info com.valvesoftware.Steam >/dev/null 2>&1; then
        echo "Flatpak Steam is not installed yet. It is installed automatically after first boot; try again once it shows up."
        exit 1
    fi
    # Vulkan layer extensions must match the freedesktop runtime branch the launcher uses
    BRANCH="$(flatpak info --show-runtime com.valvesoftware.Steam | cut -d/ -f3)"
    echo "Installing Vulkan layers for runtime branch ${BRANCH}..."
    for layer in MangoHud gamescope OBSVkCapture; do
        flatpak install -y --system --noninteractive flathub "runtime/org.freedesktop.Platform.VulkanLayer.${layer}/x86_64/${BRANCH}" \
            || echo "Warning: ${layer} is not available for runtime ${BRANCH}, skipped"
    done
    echo "Done. Use 'MANGOHUD=1 %command%' or 'gamescope -- %command%' in a game's Steam launch options."

# Show whether the gaming tweaks are active on this system
[group('Gaming')]
gaming-status:
    #!/usr/bin/bash
    echo "Kernel:            $(uname -r)"
    echo "ntsync module:     $(if [ -e /dev/ntsync ]; then echo loaded; else echo 'not available'; fi)"
    echo "vm.max_map_count:  $(sysctl -n vm.max_map_count)"
    echo "split lock mitig.: $(sysctl -n kernel.split_lock_mitigate 2>/dev/null || echo n/a)"
    echo "gamemode:          $(if command -v gamemoded >/dev/null; then echo installed; else echo 'not installed'; fi)"
    for app in com.valvesoftware.Steam net.lutris.Lutris com.heroicgameslauncher.hgl com.vysp3r.ProtonPlus; do
        printf '%-30s %s\n' "${app}:" "$(if flatpak info "${app}" >/dev/null 2>&1; then echo installed; else echo 'not installed (yet)'; fi)"
    done
