#!/usr/bin/env bash
set -euo pipefail

title() { echo -e "\n==> $1"; }

# -------------------------------------------------
# 0) Full systemoppdatering
# -------------------------------------------------
title "[0/9] Oppdaterer systemet"
sudo apt update && sudo apt upgrade -y

# -------------------------------------------------
# 1) Forberedelser (APT-kilder og oppdatering)
# -------------------------------------------------
title "[1/9] Forberedelser"
sudo dpkg --add-architecture i386 || true
sudo add-apt-repository -y multiverse
sudo apt update

# -------------------------------------------------
# 2) Verktøy som trengs for GNOME-porno
# -------------------------------------------------
title "[2/9] Installerer GNOME-verktøy og fonts (APT)"
sudo apt install -y \
  git curl wget unzip \
  gnome-tweaks gnome-shell-extensions gnome-shell-extension-manager \
  fonts-inter fonts-firacode

# -------------------------------------------------
# 3) GNOME "porno": tema/ikoner/cursor + tweaks
# -------------------------------------------------
title "[3/9] GNOME ‘porno’: Orchis, Tela, Bibata, dark mode"

# Orchis (GTK + Shell)
tmpdir="$(mktemp -d)"; pushd "$tmpdir" >/dev/null
git clone --depth=1 https://github.com/vinceliuice/Orchis-theme.git
bash Orchis-theme/install.sh -d ~/.themes -t default -c dark -s
popd >/dev/null; rm -rf "$tmpdir"

# Tela ikoner
tmpdir="$(mktemp -d)"; pushd "$tmpdir" >/dev/null
git clone --depth=1 https://github.com/vinceliuice/Tela-icon-theme.git
bash Tela-icon-theme/install.sh -d ~/.icons -a
popd >/dev/null; rm -rf "$tmpdir"

# Bibata cursor
tmpdir="$(mktemp -d)"; pushd "$tmpdir" >/dev/null
git clone --depth=1 https://github.com/ful1e5/Bibata_Cursor.git
mkdir -p ~/.icons
cp -r Bibata_Cursor/* ~/.icons/
popd >/dev/null; rm -rf "$tmpdir"

# Enable User Themes
gnome-extensions enable user-theme@gnome-shell-extensions.gcampax.github.com || true

# Utseende
gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark' || true
gsettings set org.gnome.desktop.interface gtk-theme 'Orchis-Dark' || true
gsettings set org.gnome.shell.extensions.user-theme name 'Orchis-Dark' || true
gsettings set org.gnome.desktop.interface icon-theme 'Tela' || true
gsettings set org.gnome.desktop.interface cursor-theme 'Bibata-Modern-Ice' || true

# Fonts
gsettings set org.gnome.desktop.interface font-name 'Inter 11' || true
gsettings set org.gnome.desktop.interface document-font-name 'Inter 11' || true
gsettings set org.gnome.desktop.interface monospace-font-name 'FiraCode 11' || true

# Dock + småjusteringer
gsettings set org.gnome.shell.extensions.dash-to-dock dock-position 'BOTTOM' || true
gsettings set org.gnome.shell.extensions.dash-to-dock extend-height false || true
gsettings set org.gnome.shell.extensions.dash-to-dock transparency-mode 'DYNAMIC' || true
gsettings set org.gnome.shell.extensions.dash-to-dock intellihide true || true
gsettings set org.gnome.shell.extensions.dash-to-dock click-action 'minimize-or-previews' || true
gsettings set org.gnome.shell.extensions.dash-to-dock dash-max-icon-size 44 || true
gsettings set org.gnome.mutter center-new-windows true || true
gsettings set org.gnome.desktop.interface enable-animations true || true

# -------------------------------------------------
# 4) Flathub
# -------------------------------------------------
title "[4/9] Setter opp Flathub"
sudo apt install -y flatpak gnome-software-plugin-flatpak
if ! flatpak remotes | grep -qi flathub; then
  sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
fi

# -------------------------------------------------
# 5) Faste apper du bruker (APT)
# -------------------------------------------------
title "[5/9] Installerer faste apper (APT)"
sudo apt install -y vlc libreoffice neofetch

# -------------------------------------------------
# 6) Roy-apper via Flatpak
# -------------------------------------------------
title "[6/9] Roy-apper (Flatpak): Vesktop + Spotify"
flatpak install -y flathub dev.vencord.Vesktop
flatpak install -y flathub com.spotify.Client

# -------------------------------------------------
# 7) Gaming
# -------------------------------------------------
title "[7/9] Gaming: Steam (APT) + Heroic/ProtonUp-Qt/Lutris/Bottles (Flatpak)"
sudo apt install -y gamemode mangohud steam
flatpak install -y flathub com.heroicgameslauncher.hgl
flatpak install -y flathub net.davidotek.pupgui2
flatpak install -y flathub net.lutris.Lutris
flatpak install -y flathub com.usebottles.bottles

# -------------------------------------------------
# 8) Multimedia-codecs
# -------------------------------------------------
title "[8/9] Installerer multimedia-codecs"
sudo apt install -y ubuntu-restricted-extras || true

# -------------------------------------------------
# 9) Etterarbeid
# -------------------------------------------------
title "[9/9] Etterarbeid"
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
POST

# -------------------------------------------------
# 10) Vis systeminfo
# -------------------------------------------------
title "[10/10] Systeminfo"
neofetch || echo "neofetch ikke funnet"
