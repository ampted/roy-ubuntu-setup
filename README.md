# Roy Ubuntu Setup

Automatisert oppsettsskript for fersk Ubuntu-installasjon.  
Gir deg et system som er både **GNOME-porno** og **gamingklart** – med en liten gimmick på slutten.  

## Hva skriptet gjør
- Full systemoppdatering
- Setter opp GPU-drivere automatisk (NVIDIA, AMD eller Intel)
- Installerer GNOME-tema (Orchis), ikoner (Tela), cursors (Bibata) og fonter (Inter, FiraCode)
- Justerer GNOME (dock, dark mode, tweaks)
- Setter opp Flathub
- Installerer faste apper: VLC, LibreOffice, Neofetch
- Installerer Roy-apper: Vesktop (Discord-klient) og Spotify
- Gaming-støtte: Steam, Heroic Games Launcher, ProtonUp-Qt, Lutris, Bottles
- Installerer multimedia-codecs
- Installerer **PrismLauncher** (Minecraft) som en morsom gimmick
- Viser systeminfo (Neofetch) når alt er ferdig

## Bruk
På en fersk Ubuntu:

```bash
sudo apt update && sudo apt install -y git
git clone https://github.com/ampted/roy-ubuntu-setup.git
cd roy-ubuntu-setup
chmod +x roy-ubuntu-setup.sh
./roy-ubuntu-setup.sh
