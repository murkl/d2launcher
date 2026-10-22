#!/usr/bin/env bash
# Installs the newest cnc-ddraw with its settings program.
set -euo pipefail

zip="${D2_CACHE}/cnc-ddraw.zip"
curl --proto '=https' --proto-redir '=https' -fsSL -o "${zip}.part" \
    https://github.com/FunkyFr3sh/cnc-ddraw/releases/latest/download/cnc-ddraw.zip
mv -f "${zip}.part" "$zip"
unzip -qo "$zip" -d "$D2_DIR"
echo 'cnc-ddraw runs with the launch option -ddraw. Settings › Tools › cnc-ddraw Settings changes it.'
