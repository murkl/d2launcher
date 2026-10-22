#!/usr/bin/env bats
# shellcheck disable=SC2016  # launcher runs the code it is given, in a shell of its own

setup() {
    # shellcheck source=tests/helper.bash
    source "${BATS_TEST_DIRNAME}/helper.bash"
    setup_launcher
    game="${d2}/bin/diablo2"
}

@test "Wine variables of the shell stay away from the game, the launch options reach it" {
    fake_wine
    mkdir -p "$game"
    export WINEARCH=win32 WINEDLLOVERRIDES=mshtml=d WINEDEBUG=+all
    run launcher 'launch_options="WINEDEBUG=+seh %command%" && launch "Diablo II.exe"'
    [ "$status" -eq 0 ]
    grep -qx "env=WINEPREFIX=${d2}/wineprefix WINEDEBUG=+seh WINEDLLOVERRIDES=ddraw=n,b;winemenubuilder.exe=d WINEARCH=unset PULSE_LATENCY_MSEC=" \
        "${STUB}/wine"
}

@test "a bundled Wine of another version gives way, after the savegames are saved" {
    local saves="${d2}/wineprefix/drive_c/users/steamuser/AppData/Roaming/MedianXL" new="${BATS_TEST_TMPDIR}/new" sum
    fake_wine
    STUB_WINE_VERSION=wine-old run launcher 'run_wine wineboot --init'
    mkdir -p "${saves}/save"
    printf 'hero' >"${saves}/save/hero.d2s"
    mkdir -p "${new}/wine-new/bin"
    printf '#!/usr/bin/env bash\n[[ ${1:-} != --version ]] || exec echo wine-new\nexec %q "$@"\n' \
        "${BATS_TEST_DIRNAME}/stub/wine" >"${new}/wine-new/bin/wine"
    chmod +x "${new}/wine-new/bin/wine"
    tar -cJf "${new}.tar.xz" -C "$new" wine-new
    serve https://get.example/wine.tar.xz <"${new}.tar.xz"
    sum="$(sha256sum "${new}.tar.xz")"
    : >"${STUB}/wine"
    STUB_WINE_VERSION=wine-old run launcher \
        "WINE_URL=https://get.example/wine.tar.xz WINE_SHA256=${sum%% *} WINE_VERSION=wine-new && ready_wine"
    [ "$status" -eq 0 ]
    [ "$(STUB_WINE_VERSION=wine-old "${d2}/bin/wine/bin/wine" --version)" = wine-new ]
    run unzip -p "${d2}"/backup/d2launcher-mxl-save-*.zip save/hero.d2s
    [ "$output" = hero ]
    grep -qx 'arg=--update' "${STUB}/wine"
    grep -q 'launcher  Wine: wine-new at ' "${d2}/logs/d2launcher.log"
}

@test "a Wine download with another sha256 leaves the Wine in place" {
    fake_wine
    printf 'not a wine' | serve https://get.example/wine.tar.xz
    run launcher "WINE_URL=https://get.example/wine.tar.xz WINE_SHA256=$(printf '0%.0s' {1..64}) WINE_VERSION=wine-new && install_wine"
    [ "$status" -ne 0 ]
    [ "$(STUB_WINE_VERSION=wine-old "${d2}/bin/wine/bin/wine" --version)" = wine-old ]
}

@test "the bundled Wine of the pinned version stays and sets up the prefix" {
    fake_wine
    run launcher ready_wine
    [ "$status" -eq 0 ]
    run grep '^arg=' "${STUB}/wine"
    [ "${lines[*]:0:2}" = 'arg=wineboot arg=--init' ]
    [ -d "${d2}/wineprefix/drive_c/users/steamuser/AppData/Roaming/MedianXL/save" ]
}

@test "Game.exe alone sees Windows 7, set once" {
    fake_wine
    launcher ready_wine
    launcher ready_wine
    run grep -c '^arg=reg$' "${STUB}/wine"
    [ "$output" -eq 1 ]
    grep -qx 'arg=HKCU\\Software\\Wine\\AppDefaults\\Game.exe' "${STUB}/wine"
    grep -A1 -x '\[Software\\\\Wine\\\\AppDefaults\\\\Game.exe\] 0' "${d2}/wineprefix/user.reg" | grep -qx '"Version"="win7"'
}

@test "the prefix is set up and updated without the installers of Mono and Gecko" {
    fake_wine
    run launcher ready_wine
    [ "$status" -eq 0 ]
    grep -qx 'env=WINEPREFIX=.* WINEDEBUG=fixme-all WINEDLLOVERRIDES=ddraw=n,b;winemenubuilder.exe=d;mscoree=d;mshtml=d WINEARCH=unset PULSE_LATENCY_MSEC=' \
        "${STUB}/wine"
}

@test "the bundled Wine is not downloaded off x86_64" {
    run launcher 'uname() { echo aarch64; } && install_wine'
    [ "$status" -eq 1 ]
    [ "$output" = 'The bundled Wine runs on x86_64, this is aarch64. Set wine to a Wine of your own.' ]
    [ ! -e "${STUB}/requests" ]
}
