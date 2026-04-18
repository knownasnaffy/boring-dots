#!/bin/bash

# Original file: https://github.com/nzxlabs/Beeper-install/blob/main/Beeper_Linux_update.sh
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

APPDIR="$HOME/.local/opt/Beeper"
WORKDIR=$(mktemp -d /tmp/beeper_update_XXXXXX)
trap 'rm -rf "$WORKDIR"' EXIT

BEEPER_URL_BASE="https://api.beeper.com/desktop/download/linux"

echo "Detecting architecture..."
ARCH=$(uname -m)
case "$ARCH" in
    x86_64)
        BEEPER_URL="$BEEPER_URL_BASE/x64/stable/com.automattic.beeper.desktop"
        ;;
    aarch64|arm64)
        BEEPER_URL="$BEEPER_URL_BASE/arm64/stable/com.automattic.beeper.desktop"
        ;;
    *)
        echo "Unsupported architecture: $ARCH"
        exit 1
        ;;
esac

if [[ ! -d "$APPDIR" ]]; then
    echo "Error: Beeper is not installed in $APPDIR"
    exit 1
fi

echo "Downloading latest Beeper..."
aria2c --dir="$WORKDIR" --out="Beeper.AppImage" \
    --summary-interval=0 --console-log-level=warn \
    "$BEEPER_URL"

if [[ ! -s "$WORKDIR/Beeper.AppImage" ]]; then
    echo "Download failed."
    exit 1
fi

chmod +x "$WORKDIR/Beeper.AppImage"

echo "Backing up current version..."
if [[ -f "$APPDIR/Beeper.AppImage" ]]; then
    mv "$APPDIR/Beeper.AppImage" "$APPDIR/Beeper.AppImage.old"
fi

echo "Installing update..."
mv "$WORKDIR/Beeper.AppImage" "$APPDIR/Beeper.AppImage"

echo "Update complete."
