#!/usr/bin/env bash
# Renders docs/banner.png out of docs/banner.html: two windows of the launcher as
# zenity draws them in its dark style, its icon, and the tagline of docs/README.md.
# Runs in a throwaway Arch, as `make banner` starts it.
# Usage: banner.sh <version the windows show>
set -euo pipefail
cd "$(dirname "$0")/.."

# Metamorphous, the free face nearest to the arcane forms of Diablo II's Exocet.
# No Arch package has it, so it comes from Google Fonts at a pinned commit.
METAMORPHOUS_URL='https://raw.githubusercontent.com/google/fonts/45e3d5269e4a17d823f6d84470bc084dc5ae46f6/ofl/metamorphous/Metamorphous-Regular.ttf'
METAMORPHOUS_SHA256='55939a5664e06807e87fa4af64f52039ead12f002dda8317393fdce2f7ff57fe'
# The windows' size on the screen: libadwaita's corners of 15 and 18 pixels
# stay whole at twice the pixels.
scale=2/3

out=target/banner
rm -rf "$out"
mkdir -p "$out"

# The README's tagline, the paragraph under its banner, so the banner cannot
# come to say something else. Its bold stays the README's.
tagline="$(awk '/src="banner\.png"/ { found = 1; next } found && NF { print; exit }' docs/README.md)"
if [[ $tagline != '<p>'*'</p>' ]]; then
    echo "docs/README.md: no <p> line under the banner to take the tagline from" >&2
    exit 1
fi
tagline="${tagline#<p>}"
tagline="${tagline%</p>}"
tagline="${tagline//<b>/}"
tagline="${tagline//<\/b>/}"

# An X server of its own at twice the pixels, and zenity on it as on GNOME in its
# dark style, with the accent closest to the fire of Diablo II.
Xvfb :99 -screen 0 2400x1800x24 -br -nolisten tcp &
xvfb=$!
trap 'kill "$xvfb"' EXIT
for _ in {1..50}; do
    [[ ! -S /tmp/.X11-unix/X99 ]] || break
    sleep 0.1
done
export DISPLAY=:99 GDK_BACKEND=x11 GDK_SCALE=2 GSK_RENDERER=cairo NO_AT_BRIDGE=1 \
    ADW_DEBUG_COLOR_SCHEME=prefer-dark ADW_DEBUG_ACCENT_COLOR=orange

# A window of the launcher alone on the screen, once two captures in a row agree,
# cut out of the black around it and out of the 5 pixels of frame GTK draws
# without a compositor, then scaled.
shot() {
    local name="$1" pid sum last='' pixels _
    shift
    set -m
    "$@" >/dev/null 2>&1 &
    pid=$!
    set +m
    for _ in {1..100}; do
        sleep 0.2
        sum="$(import -window root -silent png:- | sha1sum)"
        [[ $sum != "$last" ]] || break
        last="$sum"
    done
    import -window root -silent "${out}/${name}.png"
    kill -- -"$pid"
    wait "$pid" || true
    magick "${out}/${name}.png" -trim +repage -shave 10x10 +repage "${out}/${name}.png"
    # The corner and a pixel inside differ while frame is left.
    pixels="$(magick "${out}/${name}.png" -format '%[hex:p{0,0}] %[hex:p{8,8}]' info:)"
    if [[ ${pixels% *} != "${pixels#* }" ]]; then
        echo "banner: the frame around the ${name} window changed, measure it anew" >&2
        exit 1
    fi
    magick "${out}/${name}.png" -filter Lanczos -resize "%[fx:w*${scale}]x" "${out}/${name}.png"
}

# The launcher's own dialogs, at the version the banner shows, with Median XL
# and the bundled Wine installed.
# shellcheck source=d2launcher
source ./d2launcher
places
defaults
VERSION="$1"
icon_option=(--icon="${icon}")
installed_tag() { printf 2.14.6; }
wine="${out}/wine"
printf '#!/bin/sh\necho %q\n' "$WINE_VERSION" >"$wine"
chmod +x "$wine"
shot menu ui_menu Menu Exit Play 'Median XL' Tweaks Settings
shot update ui_ask 'Median XL 2.14.7 is available.' --ok-label=Update --cancel-label='Play 2.14.6'

# Metamorphous where fontconfig looks for chromium alone, then every face the banner
# names as chromium will find it: a missing one falls back without a word.
fonts="${PWD}/${out}/share"
mkdir -p "${fonts}/fonts"
fetch_file "$METAMORPHOUS_URL" "${fonts}/fonts/Metamorphous.ttf"
printf '%s  %s\n' "$METAMORPHOUS_SHA256" "${fonts}/fonts/Metamorphous.ttf" | LC_ALL=C sha256sum -c --quiet
for face in Metamorphous 'Cormorant Garamond'; do
    if [[ $(XDG_DATA_HOME="$fonts" fc-match -f '%{family[0]}' "$face") != "$face" ]]; then
        echo "banner: no font ${face}" >&2
        exit 1
    fi
done

cp d2launcher.svg "$out/"
html="$(<docs/banner.html)"
html="${html//'{{TAGLINE}}'/$tagline}"
printf '%s\n' "${html//'{{SCALE}}'/$scale}" >"${out}/banner.html"
if grep -n '{{' "${out}/banner.html" >&2; then
    echo "banner: a placeholder is left" >&2
    exit 1
fi
XDG_DATA_HOME="$fonts" chromium --headless --no-sandbox --force-device-scale-factor=2 --default-background-color=00000000 \
    --hide-scrollbars --window-size=1280,640 --screenshot="${out}/banner.png" "file://${PWD}/${out}/banner.html" 2>/dev/null

# 256 colors and the whole alpha, as the banners of Arch OS: the fading shadows
# band in a palette. pngquant dithers only where a gradient needs it, so the
# fire stays smooth and the windows flat.
magick "${out}/banner.png" -alpha off "${out}/colors.png"
pngquant --force --speed 1 --output "${out}/colors.png" 256 "${out}/colors.png"
magick "${out}/banner.png" "${out}/colors.png" +swap -compose CopyOpacity -composite \
    -strip -define png:compression-level=9 -define png:compression-filter=1 -define png:compression-strategy=0 \
    docs/banner.png
echo "docs/banner.png  $(stat -c %s docs/banner.png) bytes"
