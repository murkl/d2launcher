#!/usr/bin/env bash
# Checks in a throwaway container that D2Launcher runs on a distribution with
# what the project names for it and nothing more: its line in docs/README.md,
# or the depends of aur/PKGBUILD on Arch. The launcher then finds its tools, and
# its Wine installs as for a user, reports its version and runs a 32-bit program
# without a Wine of the system or a 32-bit library.
# Usage: distro-check.sh <arch|debian|ubuntu|fedora|opensuse>
set -euo pipefail
cd "$(dirname "$0")/.."

if [ ! -f /.dockerenv ]; then
    echo "distro-check: runs in a throwaway container only, as make distro-check does" >&2
    exit 1
fi

# The line of the distribution, its sudo left out. A container lacks what every
# desktop has, which comes on top: certificates, procps, util-linux, xz.
reference() {
    local line
    line="$(sed -n "s/^| [^|]*$1[^|]* | \`sudo \([^\`]*\)\` |$/\1/p" docs/README.md)"
    if [ -z "$line" ]; then
        echo "distro-check: docs/README.md has no line for $1" >&2
        exit 1
    fi
    read -ra words <<<"$line"
    packages=("${words[@]:2}")
}

case "${1:-}" in
arch)
    # shellcheck source=aur/PKGBUILD
    source aur/PKGBUILD
    pacman -Syu --noconfirm --needed "${depends[@]}" >/dev/null
    ;;
debian | ubuntu)
    reference "${1^}"
    apt-get update -qq
    DEBIAN_FRONTEND=noninteractive apt-get install -y -qq --no-install-recommends \
        "${packages[@]}" ca-certificates procps xz-utils >/dev/null
    ;;
fedora)
    reference Fedora
    dnf install -y -q "${packages[@]}" procps-ng util-linux xz >/dev/null
    ;;
opensuse)
    reference openSUSE
    zypper -n -q install "${packages[@]}" procps util-linux xz gzip tar >/dev/null
    ;;
*)
    echo "usage: tools/distro-check.sh arch|debian|ubuntu|fedora|opensuse" >&2
    exit 2
    ;;
esac

# shellcheck source=d2launcher
source ./d2launcher
for command in "${REQUIRES[@]}"; do
    if ! command -v "$command" >/dev/null; then
        echo "distro-check: $1 lacks ${command}" >&2
        exit 1
    fi
done

HOME="$(mktemp -d)"
trap 'rm -rf "$HOME"' EXIT
places
defaults
mkdir -p "$cache" "$logs"
run="$(mktemp -d -p "$cache")"
install_wine
setup_prefix --init
with_wine "$wine" "${wine_home}/lib/wine/i386-windows/cmd.exe" /c echo 32-bit 2>/dev/null | tr -d '\r' >"${run}/out"
grep -qx 32-bit "${run}/out"
echo "distro-check: $1 runs $("$wine" --version) with what the project names"
