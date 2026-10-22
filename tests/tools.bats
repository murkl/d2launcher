#!/usr/bin/env bats
# shellcheck disable=SC2016  # launcher runs the code it is given, in a shell of its own

setup() {
    # shellcheck source=tests/helper.bash
    source "${BATS_TEST_DIRNAME}/helper.bash"
    setup_launcher
    game="${d2}/bin/diablo2"
}

@test "a failed D2Stats download keeps the D2Stats you have" {
    mkdir -p "${d2}/bin/d2-stats"
    printf 'old' >"${d2}/bin/d2-stats/D2Stats.exe"
    run launcher install_d2stats
    [ "$status" -ne 0 ]
    [ "$(cat "${d2}/bin/d2-stats/D2Stats.exe")" = old ]
}

@test "a new D2Stats keeps your settings, notifier rules and sounds" {
    mkdir -p "${d2}/bin/d2-stats/NotifierRules" "${BATS_TEST_TMPDIR}/zip"
    printf 'mine' >"${d2}/bin/d2-stats/D2Stats.exe.ini"
    printf 'rule' >"${d2}/bin/d2-stats/NotifierRules/a.rule"
    printf 'new' >"${BATS_TEST_TMPDIR}/zip/D2Stats.exe"
    printf 'default' >"${BATS_TEST_TMPDIR}/zip/D2Stats.exe.ini"
    (cd "${BATS_TEST_TMPDIR}/zip" && zip -q "${BATS_TEST_TMPDIR}/D2Stats.zip" D2Stats.exe D2Stats.exe.ini)
    serve https://github.com/azadix/D2Stats/releases/latest/download/D2Stats.zip <"${BATS_TEST_TMPDIR}/D2Stats.zip"
    run launcher install_d2stats
    [ "$status" -eq 0 ]
    [ "$(cat "${d2}/bin/d2-stats/D2Stats.exe")" = new ]
    [ "$(cat "${d2}/bin/d2-stats/D2Stats.exe.ini")" = mine ]
    [ "$(cat "${d2}/bin/d2-stats/NotifierRules/a.rule")" = rule ]
}

@test "a restore replaces the game folder, each time" {
    mkdir -p "$game"
    printf 'saved' >"${game}/Game.exe"
    launcher backup_game
    printf 'broken' >"${game}/Game.exe"
    launcher restore_game
    launcher restore_game
    [ "$(cat "${game}/Game.exe")" = saved ]
    run ls "${d2}/bin"
    [ "$output" = diablo2 ]
}

@test "a restore keeps the saves in the game folder" {
    mkdir -p "${game}/save"
    launcher backup_game
    printf 'hero' >"${game}/save/hero.d2s"
    launcher restore_game
    [ "$(cat "${game}/save/hero.d2s")" = hero ]
}

@test "a folder without Game.exe, or without the space for the rest, is refused before a copy" {
    local from="${BATS_TEST_TMPDIR}/d2"
    mkdir -p "$from"
    touch "${from}/"{d2char,d2data,d2exp,d2music,d2sfx,d2speech,d2video,d2xmusic,d2xtalk,d2xvideo}.mpq
    answer 0 "$from"
    run launcher setup_game
    [ "$status" -eq 1 ]
    grep -q -- "--error --width=360 --text=${from} holds no Game.exe." "${STUB}/calls"
    touch "${from}/Game.exe"
    echo 1000 >"${STUB}/free"
    answer 0 "$from"
    run launcher setup_game
    [ "$status" -eq 1 ]
    grep -Eq -- "--error --width=360 --text=Diablo II needs [0-9.]+GiB free in ${d2}, there are 1000B." "${STUB}/calls"
    [ ! -e "$game" ]
}

@test "Diablo II alone keeps its saves in Saved Games, before 1.14 in the game folder" {
    mkdir -p "${d2}/bin/diablo2-vanilla"
    printf 'median_xl=false\n' >"${d2}/d2launcher.conf"
    run launcher 'use_settings && saves'
    [ "$output" = "${d2}/wineprefix/drive_c/users/player/Saved Games/Diablo II" ]
    touch "${d2}/bin/diablo2-vanilla/D2Client.dll"
    run launcher 'use_settings && saves'
    [ "$output" = "${d2}/bin/diablo2-vanilla/save" ]
}

@test "D2GL gets start values where it has no settings, and yours stay" {
    mkdir -p "$game"
    launcher seed_d2gl
    [ ! -e "${game}/d2gl.ini" ]
    touch "${game}/d2gl.mpq"
    launcher seed_d2gl
    grep -qxF 'shader_preset=xbr\xbr-lv2-sharp.slangp' "${game}/d2gl.ini"
    printf 'mine\n' >"${game}/d2gl.ini"
    launcher seed_d2gl
    [ "$(cat "${game}/d2gl.ini")" = mine ]
}

@test "a copy that fails leaves no half game folder" {
    run launcher 'copy_game /no/such/folder'
    [ "$status" -ne 0 ]
    [ ! -e "$game" ]
}

@test "a folder without the MPQs of a full installation is named" {
    mkdir -p "${BATS_TEST_TMPDIR}/d2"
    touch "${BATS_TEST_TMPDIR}/d2/"{D2CHAR,d2data,d2exp,d2music,d2sfx,d2speech,d2video,D2xMusic,d2xtalk}.mpq
    run launcher "missing_mpqs ${BATS_TEST_TMPDIR}/d2"
    [ "$output" = 'd2xvideo.mpq ' ]
}

@test "versions sort by number, newest first" {
    mkdir -p "${d2}/patches"
    touch "${d2}/patches/"{2.9.1,2.10.0,2.14.6}.sha1
    run launcher versions
    [ "${lines[*]}" = '2.14.6 2.10.0 2.9.1' ]
}

@test "an import keeps your savegames in the backup folder" {
    local saves="${d2}/wineprefix/drive_c/users/player/AppData/Roaming/MedianXL"
    mkdir -p "${saves}/save" "${BATS_TEST_TMPDIR}/import/save"
    printf 'mine' >"${saves}/save/hero.d2s"
    printf 'theirs' >"${BATS_TEST_TMPDIR}/import/save/hero.d2s"
    (cd "${BATS_TEST_TMPDIR}/import" && zip -qr "${BATS_TEST_TMPDIR}/d2launcher-mxl-save-1.zip" .)
    touch "${d2}/wineprefix/system.reg"
    fake_wine
    answer 0 "${BATS_TEST_TMPDIR}/d2launcher-mxl-save-1.zip"
    run launcher import_saves
    [ "$status" -eq 0 ]
    [ "$(cat "${saves}/save/hero.d2s")" = theirs ]
    run unzip -p "${d2}"/backup/d2launcher-mxl-save-*.zip save/hero.d2s
    [ "$output" = mine ]
}

@test "a copy unpacked by hand updates itself file by file from a release" {
    local release="${BATS_TEST_TMPDIR}/release/d2launcher-9.9.9" sum
    mkdir -p "${release}/tweaks"
    cp -r "${app}"/{d2launcher,d2launcher.desktop,d2launcher.svg} "$release/"
    sed -i "s/^VERSION='{{VERSION}}'$/VERSION='9.9.9'/" "${release}/d2launcher"
    printf 'echo new\n' >"${release}/tweaks/new.sh"
    tar -czf "${BATS_TEST_TMPDIR}/release.tar.gz" -C "${BATS_TEST_TMPDIR}/release" d2launcher-9.9.9
    serve https://get.example/release.tar.gz <"${BATS_TEST_TMPDIR}/release.tar.gz"
    sum="$(sha256sum "${BATS_TEST_TMPDIR}/release.tar.gz")"
    run launcher "install_release 9.9.9 https://get.example/release.tar.gz sha256:${sum%% *}"
    [ "$status" -eq 0 ]
    [ "$("${app}/d2launcher" --version)" = 9.9.9 ]
    [ "$(ls "${app}/tweaks")" = new.sh ]
    run ls -A "$app"
    [ "${lines[*]}" = 'd2launcher d2launcher.desktop d2launcher.svg tweaks' ]
}

@test "a release with another sha256 is not installed" {
    printf 'not a release' | serve https://get.example/release.tar.gz
    run launcher "install_release 9.9.9 https://get.example/release.tar.gz sha256:$(printf '0%.0s' {1..64})"
    [ "$status" -ne 0 ]
    [ "$("${app}/d2launcher" --version)" = unknown ]
}

@test "a checkout is no copy to update or to give a menu entry" {
    mkdir "${app}/.git"
    run launcher portable
    [ "$status" -ne 0 ]
}
