#!/usr/bin/env bash
# Installs the newest D2GL, GavinK88's for Median XL or bayaraa's for Diablo II.
set -euo pipefail

if [[ -f ${D2_DIR}/D2Sigma.dll ]]; then
    url=https://github.com/GavinK88/d2gl-mxl-1.0/releases/latest/download/Release.zip
else
    # bayaraa names each zip after its version.
    url="$(curl --proto '=https' --proto-redir '=https' -fsSL https://api.github.com/repos/bayaraa/d2gl/releases/latest |
        jq -er 'first(.assets[] | select(.name | endswith(".zip")) | .browser_download_url)')"
fi
zip="${D2_CACHE}/d2gl.zip"
curl --proto '=https' --proto-redir '=https' -fsSL -o "${zip}.part" "$url"
mv -f "${zip}.part" "$zip"
unzip -qo "$zip" -x '*.md' -d "$D2_DIR"
echo 'D2GL runs with the launch option -3dfx, the default. Ctrl+O opens its settings in the game.'
