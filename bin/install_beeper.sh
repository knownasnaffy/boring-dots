#!/bin/bash

# Original file: https://github.com/nzxlabs/Beeper-install/blob/main/Beeper_Linux_install.sh
# Licensed under MIT. Below is the copy of the original license which applies to this file as well.
#
# MIT License
#
# Copyright (c) 2025 NaazimCo
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

set -euo pipefail

GREEN="$(tput setaf 2)"
CYAN="$(tput setaf 6)"
YELLOW="$(tput setaf 3)"
RED="$(tput setaf 1)"
RESET="$(tput sgr0)"

gum log --time --structured --level info "Detecting Linux distribution..."

install_deps() {
    if command -v dnf >/dev/null; then
        echo "${CYAN}Installing prerequisites with DNF...${RESET}"
        sudo dnf install -y nss libnotify libsecret fuse3 fuse-libs aria2 desktop-file-utils || true

    elif command -v pacman >/dev/null; then
        echo "${CYAN}Installing prerequisites with Pacman...${RESET}"
        sudo pacman -Syu --noconfirm nss libnotify libsecret fuse aria2 desktop-file-utils || true

    else
        echo "${YELLOW}WARNING: Unsupported distribution. Attempting installation anyway...${RESET}"
    fi
}

install_deps

ARCH=$(uname -m)
case "$ARCH" in
    x86_64)
        BEEPER_URL="https://api.beeper.com/desktop/download/linux/x64/stable/com.automattic.beeper.desktop"
        ;;
    aarch64|arm64)
        BEEPER_URL="https://api.beeper.com/desktop/download/linux/arm64/stable/com.automattic.beeper.desktop"
        ;;
    *)
        echo "${RED}Unsupported architecture: $ARCH${RESET}"
        exit 1
        ;;
esac

WORKDIR=$(mktemp -d /tmp/beeper_install_XXXXXX)
APPDIR="$HOME/.local/opt/Beeper"

EXTRACTED_APPIMAGE_DIR="$WORKDIR/squashfs-root"

ICONPATH_COMMON="share/icons/hicolor/512x512/apps/beepertexts.png"
ICONPATH_EXTRACTED="$EXTRACTED_APPIMAGE_DIR/usr/$ICONPATH_COMMON"
ICONPATH_FINAL="$HOME/.local/$ICONPATH_COMMON"

DESKTOP_FILE="$EXTRACTED_APPIMAGE_DIR/beepertexts.desktop"

mkdir -p "$APPDIR" "$(dirname "$ICONPATH_FINAL")" "$HOME/.local/share/applications"
trap 'rm -rf "$WORKDIR"' EXIT

echo "${CYAN}Downloading Beeper AppImage...${RESET}"
aria2c --dir="$WORKDIR" --out="Beeper.AppImage"  --summary-interval=0 --console-log-level=warn "$BEEPER_URL"

if [[ ! -s "$WORKDIR/Beeper.AppImage" ]]; then
    echo "${RED}Error: Beeper.AppImage download failed or is empty.${RESET}"
    exit 1
fi

chmod +x "$WORKDIR/Beeper.AppImage"

echo "${CYAN}Extracting Beeper icon...${RESET}"
cd "$WORKDIR"
./Beeper.AppImage --appimage-extract

echo "${CYAN}Installing Beeper...${RESET}"

mv "$WORKDIR/Beeper.AppImage" "$APPDIR/Beeper.AppImage"
[[ -f "$ICONPATH_EXTRACTED" ]] && mv "$ICONPATH_EXTRACTED" "$ICONPATH_FINAL"
command -v gtk-update-icon-cache >/dev/null && gtk-update-icon-cache --ignore-theme-index ~/.local/share/icons/hicolor

sed -i "s|^Exec=.*AppRun\(.*\)|Exec=$APPDIR/Beeper.AppImage\1|" "$DESKTOP_FILE"

desktop-file-install --dir="$HOME/.local/share/applications" "$DESKTOP_FILE"
update-desktop-database ~/.local/share/applications 2>/dev/null || true

echo "Desktop entry installed"


echo "${GREEN}Beeper installation completed successfully!${RESET}"
echo "You can now launch Beeper from your application menu."

