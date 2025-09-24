#!/usr/bin/env bash
set -euo pipefail

title() { echo -e "\n==> $1"; }

# -------------------------------------------------
# 0) Full systemoppdatering
# -------------------------------------------------
title "[0/11] Oppdaterer systemet"
sudo apt update && sudo apt upgrade -y

# -------------------------------------------------
# 1) Forberedelser (APT-kilder)
# -------------------------------------------------
title "[1/11] Forberedelser"
sudo dpkg --add-architecture i386 || true
sudo add-apt-repository -y multiverse
sudo apt update

# -------------------------------------------------
# 2) Skjermdrivere / GPU + Vulkan
# -------------------------------------------------
title "[2/11] Setter opp GPU-drivere og Vulkan"
sudo apt install -y ubuntu-drivers-common vulkan-tools libvulkan1

GPU_INFO="$(lspci | egrep -i 'vga|3d|display' | tr '[:upper:]' '[:lower:]')"

if echo "$GPU_INFO" | grep -q 'nvidia'; then
  echo "➤ Oppdaget NVIDIA → installerer proprietære drivere"
  sudo ubuntu-drivers autoinstall || true
  sudo apt install -y nvidia-settings nvidia-prime

elif echo "$GPU_INFO" | egrep -q 'amd|advanced micro devices|radeon'; then
  echo "➤ Oppdaget AMD → installerer Mesa + Vulkan"
  sudo dpkg --add-architecture i386 || true
  sudo apt update
  sudo apt install -y mesa-vulkan-drivers mesa-vulkan-drivers:i386 libvulkan1:i386

elif echo "$GPU_INFO" | egrep -q 'intel'; then
  echo "➤ Oppdaget Intel → installerer Mesa + Vulkan"
  sudo dpkg --add-architecture i386 || true
  sudo apt update
  sudo apt install -y mesa-vulkan-drivers mesa-vulkan-drivers:i386 libvulkan1:i386
  sudo apt install -y intel-media-va-driver-non-free || true

else
  echo "⚠ Fant ingen kjent GPU i: $GPU_INFO"
  echo "Hopper over GPU-driver installasjon."
fi

# -------------------------------------------------
# 3) GNOME "porno": tema/ikoner/cursor + tweaks (ROBUST)
# -------------------------------------------------
title "[3/11] GNOME ‘porno’: Orchis, Tela, Bibata (system-wide) + dark mode"

# Verktøy
sudo apt install -y \
  git curl wget unzip \
  gnome-tweaks gnome-shell-extensions gnome-shell-extension-manager \
  fonts-inter fonts-firacode

# --- Orchis (GTK + Shell) system-wide ---
tmpdir="$(mktemp -d)"; pushd "$tmpdir" >/dev/null
git clone --depth=1 https://github.com/vinceliuice/Orchis-theme.git
# -d /usr/share/themes = system-wide
sudo bash Orchis-theme/install.sh -d /usr/share/themes -t default -c dark -s
popd >/dev/null; rm -rf "$tmpdir"

# --- Tela ikoner system-wide ---
tmpdir="$(mktemp -d)"; pushd "$tmpdir" >/dev/null
git clone --depth=1 https://github.com/vinceliuice/Tela-icon-theme.git
sudo bash Tela-icon-theme/install.sh -d /usr/share/icons -a
popd >/dev/null; rm -rf "$tmpdir"

# --- Bibata cursor system-wide ---
tmpdir="$(mktemp -d)"; pushd "$tmpdir" >/dev/null
git clone --depth=1 https://github.com/ful1e5/Bibata_Cursor.git
sudo mkdir -p /usr/share/icons
sudo cp -r Bibata_Cursor/* /usr/share/icons/
popd >/dev/null; rm -rf "$tmpdir"

# --- Aktiver User Themes (for GNOME Shell-tema) ---
# NB: På Wayland må du logge ut/inn for at ny extension skal bite skikkelig.
gnome-extensions enable user-theme@gnome-shell-extensions.gcampax.github.com || true

# --- Sett dark + tema/ikoner/cursor/fonts ---
gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark' || true
gsettings set org.gnome.desktop.interface gtk-theme 'Orchis-Dark' || true
gsettings set org.gnome.shell.extensions.user-theme name 'Orchis-Dark' || true
gsettings set org.gnome.desktop.interface icon-theme 'Tela' || true
gsettings set org.gnome.desktop.interface cursor-theme 'Bibata-Modern-Ice' || true

gsettings set org.gnome.desktop.interface font-name 'Inter 11' || true
gsettings set org.gnome.desktop.interface document-font-name 'Inter 11' || true
gsettings set org.gnome.desktop.interface monospace-font-name 'FiraCode 11' || true

# --- Dock & småjusteringer (Ubuntu Dock/dash-to-dock) ---
gsettings set org.gnome.shell.extensions.dash-to-dock dock-position 'BOTTOM' || true
gsettings set org.gnome.shell.extensions.dash-to-dock extend-height false || true
gsettings set org.gnome.shell.extensions.dash-to-dock transparency-mode 'DYNAMIC' || true
gsettings set org.gnome.shell.extensions.dash-to-dock intellihide true || true
gsettings set org.gnome.shell.extensions.dash-to-dock click-action 'minimize-or-previews' || true
gsettings set org.gnome.shell.extensions.dash-to-dock dash-max-icon-size 44 || true
gsettings set org.gnome.mutter center-new-windows true || true
gsettings set org.gnome.desktop.interface enable-animations true || true

# --- Verifisering / debug-hint ---
echo "Tema valgt:"
echo " GTK  : $(gsettings get org.gnome.desktop.interface gtk-theme || true)"
echo " Shell: $(gsettings get org.gnome.shell.extensions.user-theme name || true)"
echo " Ikoner: $(gsettings get org.gnome.desktop.interface icon-theme || true)"
echo " Cursor: $(gsettings get org.gnome.desktop.interface cursor-theme || true)"


# -------------------------------------------------
# 4) Flathub
# -------------------------------------------------
title "[4/11] Setter opp Flathub"
sudo apt install -y flatpak gnome-software-plugin-flatpak
if ! flatpak remotes | grep -qi flathub; then
  sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
fi

# -------------------------------------------------
# 5) Faste apper du bruker (APT)
# -------------------------------------------------
title "[5/11] Installerer faste apper (APT)"
sudo apt install -y vlc libreoffice neofetch

# -------------------------------------------------
# 6) Roy-apper via Flatpak
# -------------------------------------------------
title "[6/11] Roy-apper (Flatpak): Vesktop + Spotify"
flatpak install -y flathub dev.vencord.Vesktop
flatpak install -y flathub com.spotify.Client

# -------------------------------------------------
# 7) Gaming
# -------------------------------------------------
title "[7/11] Gaming: Steam (APT) + Heroic/ProtonUp-Qt/Lutris/Bottles (Flatpak)"
sudo apt install -y gamemode mangohud steam
flatpak install -y flathub com.heroicgameslauncher.hgl
flatpak install -y flathub net.davidotek.pupgui2
flatpak install -y flathub net.lutris.Lutris
flatpak install -y flathub com.usebottles.bottles

# -------------------------------------------------
# 8) Multimedia-codecs
# -------------------------------------------------
title "[8/11] Installerer multimedia-codecs"
sudo apt install -y ubuntu-restricted-extras || true

# -------------------------------------------------
# 9) Funny gimmick: Minecraft Launcher
# -------------------------------------------------
title "[9/11] Installerer Minecraft Launcher (PrismLauncher)"
flatpak install -y flathub org.prismlauncher.PrismLauncher

# -------------------------------------------------
# 10) Etterarbeid
# -------------------------------------------------
title "[10/11] Etterarbeid"
cat <<'POST'
— Ferdig! —

Anbefalt:
1) GNOME extensions:
   Åpne "Extension Manager" → Browse → installer
   - Blur my Shell
   - Rounded Window Corners
   - Just Perfection
   Reload Shell (Alt+F2 → r → Enter) eller logg ut/inn.

2) Steam:
   Settings → Steam Play → Enable Steam Play for all titles.

3) Proton-GE:
   flatpak run net.davidotek.pupgui2
   → Installer siste "Proton-GE" for Steam (og evt. for Heroic).

4) FPS/ytelse i Steam (per spill → Launch Options):
   gamemoderun mangohud %command%

5) Vesktop:
   Start “Vesktop” fra appmenyen og logg inn (Discord-konto).

6) Minecraft:
   Start “PrismLauncher” fra appmenyen, legg til din Mojang/Microsoft-konto,
   og installer din første verden/modpack. 😎
POST

# -------------------------------------------------
# 11) Vis systeminfo
# -------------------------------------------------
title "[11/11] Systeminfo"
neofetch || echo "neofetch ikke funnet"
