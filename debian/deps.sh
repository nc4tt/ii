#!/bin/bash
set -e

# --- Configuration ---
TEMP_DIR="$HOME/.cache/dots_depends"
rm -rf "$TEMP_DIR"
mkdir -p "$TEMP_DIR"
cd "$TEMP_DIR"

# 1. Update System
sudo apt update && sudo apt upgrade -y

# 2. Add External Repositories
echo "Adding 3rd repositories..."

# Quickshell (AvengeMedia/danklinux)
echo 'deb http://download.opensuse.org/repositories/home:/AvengeMedia:/danklinux/Debian_13/ /' | sudo tee /etc/apt/sources.list.d/home:AvengeMedia:danklinux.list
curl -fsSL https://download.opensuse.org/repositories/home:AvengeMedia:danklinux/Debian_13/Release.key | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/home_AvengeMedia_danklinux.gpg > /dev/null

# Eza (Modern ls)
sudo mkdir -p /etc/apt/keyrings
wget -qO- https://raw.githubusercontent.com/eza-community/eza/main/deb.asc | sudo gpg --dearmor -o /etc/apt/keyrings/gierens.gpg
echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" | sudo tee /etc/apt/sources.list.d/gierens.list

sudo apt update

# 3. Install Core Build Tools & Hyprland Ecosystem
# Mapping: @development-tools -> build-essential, etc.
sudo apt install -y build-essential cmake clang meson ninja-build pkg-config \
    git curl wget jq gettext-base python3-dev python3-pip python3-opencv \
    hyprland hyprlock hypridle hyprpicker xdg-desktop-portal-hyprland \
    cliphist libpugixml-dev libhyprlang-dev libhyprutils-dev \
    libgtk-4-dev libadwaita-1-dev libgtk-3-dev libgtksourceview-4-dev \
    libgtksourceviewmm-3.0-dev libgjs-dev libpulse-dev \
    polkit-kde-agent-1 qalc translate-shell brightnessctl ddcutil \
    wl-clipboard xdg-utils ripgrep axel fish kitty starship \
    pavucontrol wireplumber libdbusmenu-gtk3-dev playerctl cava \
    yad scdoc ydotool libtinyxml2-dev libmagic-dev libwebp-dev \
    libdrm-dev libgbm-dev libpam0g-dev libsass-dev \
    qt5ct qt6ct qt6-wayland qt5-wayland kde-cli-tools \
    fonts-jetbrains-mono fonts-symbola fonts-lato \
    qt5-style-kvantum qt6-style-kvantum \
    swappy wf-recorder grim tesseract-ocr slurp \
    appstream-util libsoup-3.0-dev quickshell

# 4. Install Matugen (Manual GitHub Binary)
# Required for the dynamic color-generation feature
echo "🎨 Installing Matugen..."
MATUGEN_URL=$(curl -s https://api.github.com/repos/InioAsis/matugen/releases/latest | \
    jq -r '.assets[] | select(.name | test("linux-amd64|linux-x86_64")) | .browser_download_url' | head -n 1)

if [ -n "$MATUGEN_URL" ]; then
    wget -O matugen "$MATUGEN_URL"
    chmod +x matugen
    sudo mv matugen /usr/local/bin/
else
    echo "Failed to find Matugen bin file. Color generation may not work."
fi

# 5. Install Upscayl (Optional)
read -rp "Do you want to install Upscayl? (y/n): " choice
if [[ "$choice" =~ ^[Yy]$ ]]; then
    echo "🖼️ Installing Upscayl..."
    UPSCAYL_URL=$(curl -s https://api.github.com/repos/upscayl/upscayl/releases/latest | \
        jq -r '.assets[] | select(.name | test(".*amd64\\.deb$")) | .browser_download_url' | head -n 1)
    
    if [ -n "$UPSCAYL_URL" ]; then
        wget -O upscayl.deb "$UPSCAYL_URL"
        sudo apt install ./upscayl.deb -y
        rm upscayl.deb
    else
        echo "could not find Upscayl .deb file."
    fi
fi

# Cleanup
rm -rf "$TEMP_DIR"

echo "-------------------------------------------------------"
echo "Done! All dependencies are installed."
echo "You can now proceed to copy the dotfiles:"
echo "cp -r dots/.config/* ~/.config/"
echo "cp -r dots/.local/* ~/.local/"
echo "-------------------------------------------------------"
