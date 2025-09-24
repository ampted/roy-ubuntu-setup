#!/usr/bin/env bash
set -euo pipefail

title(){ echo -e "\n==> $1"; }

# -------------------------------------------------
# 0) Full systemoppdatering
# -------------------------------------------------
title "[0/8] Oppdaterer systemet"
sudo pacman -Syu --noconfirm

# -------------------------------------------------
# 1) Base: git + build-verktøy (for AUR)
# -------------------------------------------------
title "[1/8] Installerer git + base-devel"
sudo pacman -S --noconfirm --needed git base-devel curl wget unzip fastfetch

# -------------------------------------------------
# 2) Installer yay (AUR-helper) hvis mangler
# -------------------------------------------------
if ! command -v yay >/dev/null 2>&1; then
  title "[2/8] Installerer yay (AUR)"
  tmpdir="$(mktemp -d)"; pushd "$tmpdir" >/dev/null
  git clone https://aur.archlinux.org/yay-bin.git
  cd yay-bin
  makepkg -si --noconfirm
  popd >/dev/null
  rm -rf "$tmpdir"
else
  title "[2/8] yay finnes allerede – hopper over"
fi

# -------------------------------------------------
# 3) KDE "porno": tema/ikoner/cursor/font (AUR/pacman)
# -------------------------------------------------
title "[3/8] KDE ‘porno’: Sweet tema, Tela ikoner, Bibata cursor, fonter"
# Sweet (KDE/GTK/Kvantum)
yay -S --noconfirm --needed sweet-gtk-theme sweet-kde-theme sweet-cursor-theme
# Ikoner
yay -S --noconfirm --needed tela-icon-theme
# Cursor (Bibata)
yay -S --noconfirm --needed bibata-cursor-theme-bin
# Fonter
sudo pacman -S --noconfirm --needed ttf-fira-code
yay -S --noconfirm --needed inter-font

# Kvantum (for GTK/Qt harmoni med Sweet)
sudo pacman -S --noconfirm --needed kvantum-qt5 kvantum-qt6 kvantum-manager || true

# -------------------------------------------------
# 4) Flatpak/Flathub
# -------------------------------------------------
title "[4/8] Setter opp Flatpak/Flathub"
sudo pacman -S --noconfirm --needed flatpak
if ! flatpak remotes | grep -qi flathub; then
  sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
fi

# -------------------------------------------------
# 5) Roy-apper & Gaming via Flatpak
# -------------------------------------------------
title "[5/8] Installerer Flatpak-apper (Vesktop via AUR under)"
flatpak install -y flathub com.spotify.Client
flatpak install -y flathub com.heroicgameslauncher.hgl
flatpak install -y flathub net.davidotek.pupgui2
flatpak install -y flathub net.lutris.Lutris
flatpak install -y flathub com.usebottles.bottles

# -------------------------------------------------
# 6) Vesktop (Discord-klient) via AUR
# -------------------------------------------------
title "[6/8] Installerer Vesktop (AUR)"
yay -S --noconfirm --needed vesktop-bin

# -------------------------------------------------
# 7) Faste pakker via pacman
# -------------------------------------------------
title "[7/8] Installerer faste pakker (pacman)"
sudo pacman -S --noconfirm --needed vlc libreoffice-fresh steam

# -------------------------------------------------
# 8) Etterarbeid
# -------------------------------------------------
title "[8/8] Etterarbeid"
cat <<'POST'
Ferdig! 🎉

Gjør dette i KDE System Settings → Appearance:
  • Global Theme: Sweet (fra sweet-kde-theme)
  • Icons: Tela
  • Cursor: Bibata Modern (hvit/ice eller mørk/amber, etter smak)
  • Fonts: Inter (sans), Fira Code (monospace)
  • Kvantum: åpne Kvantum Manager → Select Theme → "Sweet" → Use this theme

Gaming:
  • Steam → Settings → Steam Play → Enable Steam Play for all titles
  • Proton-GE: flatpak run net.davidotek.pupgui2 → Installer siste "Proton-GE"
  • Lutris/Heroic/Bottles: logg inn og velg Proton/Wine der du vil

Tips:
  • Vesktop starter du fra appmenyen (logg på med Discord-konto).
  • Du kan når som helst installere flere AUR-ting med: yay -S <pakkenavn>
POST
