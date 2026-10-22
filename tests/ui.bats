#!/usr/bin/env bats
# shellcheck disable=SC2016  # launcher runs the code it is given, in a shell of its own

setup() {
    # shellcheck source=tests/helper.bash
    source "${BATS_TEST_DIRNAME}/helper.bash"
    setup_launcher
    game="${d2}/bin/diablo2"
}

# A line a launcher job in the background may still be writing when the
# launcher ends, waited for up to five seconds.
wait_for() {
    local _
    for _ in {1..50}; do
        ! grep -q -- "$1" "$2" 2>/dev/null || return 0
        read -rt 0.1 <> <(:) || true
    done
    return 1
}

# A game with Median XL, which brings D2GL.
installed() {
    fake_wine
    mkdir -p "$game"
    touch "${game}/Diablo II.exe" "${game}/glide3x.dll"
    echo "$1" >"${game}/d2launcher-patch.version"
}

@test "Configuration checks what you save and opens again on a mistake" {
    mkdir -p "$game"
    answer 0 Settings
    answer 0 Configuration
    answer 0 'channel=alpha'
    answer 0 'channel=beta\nlaunch_options=-ddraw'
    run "${app}/d2launcher"
    [ "$status" -eq 0 ]
    grep -q 'Line 1: channel is public or beta' "${STUB}/calls"
    run grep -Ev '^(#|$)' "${d2}/d2launcher.conf"
    [ "${lines[*]}" = 'channel=beta launch_options=-ddraw' ]
}

@test "Play starts the installed Median XL when its server is out of reach" {
    installed 2.14.6
    printf 'launch_options=-3dfx -ns\n' >"${d2}/d2launcher.conf"
    answer 0 Play
    run "${app}/d2launcher"
    [ "$status" -eq 0 ]
    run grep '^arg=' "${STUB}/wine"
    [[ "${lines[*]}" == 'arg=wineboot arg=--init '*' arg=Diablo II.exe arg=-3dfx arg=-ns' ]]
    [ -d "${d2}/wineprefix/drive_c/users/steamuser/AppData/Roaming/MedianXL/save" ]
}

@test "Play offers a new Median XL, and you may play the installed one" {
    installed 1.0
    publish_mxl 1.1 a.mpq=alpha
    answer 0 Play
    answer 1
    run "${app}/d2launcher"
    [ "$status" -eq 0 ]
    grep -q 'Median XL 1.1 is available.*--cancel-label=Play 1.0' "${STUB}/calls"
    [ "$(cat "${game}/d2launcher-patch.version")" = 1.0 ]
    grep -q '^arg=Diablo II.exe$' "${STUB}/wine"
}

@test "Play updates Median XL first when you agree" {
    installed 1.0
    publish_mxl 1.1 a.mpq=alpha
    answer 0 Play
    answer 0
    run "${app}/d2launcher"
    [ "$status" -eq 0 ]
    [ "$(cat "${game}/d2launcher-patch.version")" = 1.1 ]
    [ "$(cat "${game}/a.mpq")" = alpha ]
    grep -q '^arg=Diablo II.exe$' "${STUB}/wine"
}

@test "the help button opens the reference" {
    mkdir -p "$game"
    answer 1 '?'
    run "${app}/d2launcher"
    [ "$status" -eq 0 ]
    wait_for 'docs/REFERENCE.md' "${STUB}/opened"
}

@test "a copy unpacked by hand gets a menu entry pointing to it" {
    run "${app}/d2launcher"
    [ "$status" -eq 0 ]
    grep -qx "Exec=\"${app}/d2launcher\"" "${XDG_DATA_HOME}/applications/d2launcher.local.desktop"
    grep -qx "Icon=${app}/d2launcher.svg" "${XDG_DATA_HOME}/applications/d2launcher.local.desktop"
}

@test "a second launcher leaves the first one alone" {
    mkdir -p "$d2"
    exec 8>"${d2}/d2launcher.lock"
    flock 8
    run "${app}/d2launcher"
    exec 8>&-
    [ "$status" -eq 0 ]
    wait_for '--notification --text=D2Launcher is running already.' "${STUB}/calls"
}

@test "4.x data takes its new form at the first start" {
    mkdir -p "${d2}/patches" "${d2}/tweaks" "$game"
    cp "${BATS_TEST_DIRNAME}/fixtures/d2launcher-4.conf" "${d2}/d2launcher.conf"
    printf '###!> tweak_name: FunkyFr3sh/cnc-ddraw\n###!> tweak_version: latest\necho shipped\n\n###!> tweak_name: my/plugin\n###!> tweak_version: 1\necho mine\n' \
        >"${d2}/tweaks.db"
    touch "${d2}/tweaks/FunkyFr3sh-cnc-ddraw-latest.zip"
    (cd "$game" && printf alpha >a.mpq && zip -q0 "${d2}/patches/d2launcher-mxl-1.0.zip" a.mpq)
    echo d2launcher-mxl-1.0 >"${game}/d2launcher-patch.version"
    run "${app}/d2launcher"
    [ "$status" -eq 0 ]
    grep -qx 'launch_options=PULSE_LATENCY_MSEC=120 gamemoderun %command% -3dfx -log -dxnocompatmodefix' "${d2}/d2launcher.conf"
    [ "$(ls "${d2}/tweaks")" = my_plugin.sh ]
    grep -qx 'echo mine' "${d2}/tweaks/my_plugin.sh"
    [ -e "${XDG_CACHE_HOME}/d2launcher/tweaks/FunkyFr3sh-cnc-ddraw-latest.zip" ]
    [ ! -e "${d2}/patches/d2launcher-mxl-1.0.zip" ]
    [ -f "${game}/d2launcher-patch.sha1" ]
    run "${app}/d2launcher"
    [ "$status" -eq 0 ]
    grep -qx 'launch_options=PULSE_LATENCY_MSEC=120 gamemoderun %command% -3dfx -log -dxnocompatmodefix' "${d2}/d2launcher.conf"
}

@test "the lists show the versions of D2Launcher, Median XL and Wine, at the size of 4.x" {
    installed 2.14.6
    run "${app}/d2launcher"
    [ "$status" -eq 0 ]
    grep -q -- "--title= --icon=.* --list --width=450 --height=420 --text=<span font_family=\"monospace\" font=\"9\"><b><span foreground=\"#C8401A\">D2LAUNCHER | unknown</span>" "${STUB}/calls"
    grep -qx '<span alpha="76%">MEDIAN XL  | 2.14.6' "${STUB}/calls"
    grep -q '^WINE       | Proton 11.0-2</span></b></span>' "${STUB}/calls"
    grep -q -- '--column=Menu --ok-label=Ok --cancel-label=Exit --extra-button=? Play Median XL Tweaks Settings$' "${STUB}/calls"
}

@test "with d2stats on, Play starts D2Stats and then the game through sigma-loader" {
    installed 2.14.6
    mkdir -p "${d2}/bin/d2-stats"
    touch "${d2}/bin/d2-stats/D2Stats.exe" "${game}/sigma-loader.exe"
    printf 'd2stats=true\n' >"${d2}/d2launcher.conf"
    answer 0 Play
    run "${app}/d2launcher"
    [ "$status" -eq 0 ]
    run grep -E '^(cwd|arg)=' "${STUB}/wine"
    [[ "${lines[*]}" == *"cwd=${d2}/bin/d2-stats arg=D2Stats.exe"* ]]
    [[ "${lines[*]}" == *"cwd=${game} arg=sigma-loader.exe arg=-3dfx" ]]
}

@test "Settings offers only what can run" {
    installed 2.14.6
    answer 0 Settings
    answer 0 Tools
    answer 1
    answer 0 Backups
    run "${app}/d2launcher"
    grep -q -- '--column=Settings .* Configuration Tools Backups Update D2Launcher$' "${STUB}/calls"
    grep -q -- '--column=Tools .* Wine Configuration Run Program Reinstall Wine$' "${STUB}/calls"
    grep -q -- '--column=Backups .* Create Backup Export Saves Import Saves$' "${STUB}/calls"
    mkdir -p "${d2}/backup" "${app}/.git"
    touch "${game}/cnc-ddraw config.exe" "${d2}/backup/diablo2.tar"
    printf 'd2stats=true\n' >"${d2}/d2launcher.conf"
    : >"${STUB}/calls"
    answer 0 Settings
    answer 0 Tools
    answer 1
    answer 0 Backups
    run "${app}/d2launcher"
    grep -q -- '--column=Settings .* Configuration Tools Backups Update D2Stats$' "${STUB}/calls"
    grep -q -- '--column=Tools .* Wine Configuration cnc-ddraw Settings Run Program Reinstall Wine$' "${STUB}/calls"
    grep -q -- '--column=Backups .* Create Backup Restore Backup Export Saves Import Saves$' "${STUB}/calls"
}

@test "a submenu stays open after an action, Back goes up a level" {
    installed 2.14.6
    answer 0 Settings
    answer 0 Tools
    answer 0 'Wine Configuration'
    run "${app}/d2launcher"
    [ "$status" -eq 0 ]
    grep -qx 'arg=winecfg' "${STUB}/wine"
    run grep -o -- '--column=[A-Za-z]*' "${STUB}/calls"
    [ "${lines[*]}" = '--column=Menu --column=Settings --column=Tools --column=Tools --column=Settings --column=Menu' ]
}

@test "markup and backslashes reach a dialog as written" {
    run launcher 'esc "C:\\new <b> & co"'
    [ "$output" = 'C:\\new &lt;b&gt; &amp; co' ]
}

@test "a first start copies the folder you choose and sets up the rest, so Play starts at once" {
    local from="${HOME}/Games/diablo-ii/drive_c/Program Files/Diablo II"
    mkdir -p "$from"
    touch "${from}/Game.exe" "${from}/Diablo II.exe" \
        "${from}/"{d2char,d2data,d2exp,d2music,d2sfx,d2speech,d2video,d2xmusic,d2xtalk,d2xvideo}.mpq
    fake_wine
    publish_mxl 1.0 a.mpq=alpha glide3x.dll=glide
    answer 0 "$from"
    answer 0 Play
    run "${app}/d2launcher"
    [ "$status" -eq 0 ]
    grep -qF -- "--file-selection --directory --filename=${from}/" "${STUB}/calls"
    [ -f "${d2}/backup/diablo2.tar" ]
    [ "$(cat "${game}/d2launcher-patch.version")" = 1.0 ]
    run grep -c -- '--question' "${STUB}/calls"
    [ "$output" -eq 0 ]
    run grep '^arg=' "${STUB}/wine"
    [ "${lines[*]}" = 'arg=wineboot arg=--init arg=reg arg=add arg=HKCU\Software\Wine\AppDefaults\Game.exe arg=/v arg=Version arg=/d arg=win7 arg=/f arg=Diablo II.exe arg=-3dfx' ]
}

@test "with median_xl off, Play starts Diablo II from a folder of its own, with D2GL for -3dfx" {
    local vanilla="${d2}/bin/diablo2-vanilla"
    fake_wine
    mkdir -p "$vanilla"
    touch "${vanilla}/Diablo II.exe"
    printf 'median_xl=false\n' >"${d2}/d2launcher.conf"
    printf '{"assets": [{"name": "D2GL.v9.zip", "browser_download_url": "https://get.example/D2GL.v9.zip"}]}' |
        serve https://api.github.com/repos/bayaraa/d2gl/releases/latest
    (cd "$BATS_TEST_TMPDIR" && printf glide >glide3x.dll && printf license >LICENSE.md && zip -q d2gl.zip glide3x.dll LICENSE.md)
    serve https://get.example/D2GL.v9.zip <"${BATS_TEST_TMPDIR}/d2gl.zip"
    answer 0 Play
    run "${app}/d2launcher"
    [ "$status" -eq 0 ]
    grep -q -- '--column=Menu --ok-label=Ok --cancel-label=Exit --extra-button=? Play Tweaks Settings$' "${STUB}/calls"
    grep -qx '<span alpha="76%">MEDIAN XL  | off' "${STUB}/calls"
    [ "$(cat "${vanilla}/glide3x.dll")" = glide ]
    [ ! -e "${vanilla}/LICENSE.md" ]
    run grep -E '^(cwd|arg)=' "${STUB}/wine"
    [[ "${lines[*]}" == *"cwd=${vanilla} arg=Diablo II.exe arg=-3dfx" ]]
    run grep -c median-xl "${STUB}/requests"
    [ "$output" -eq 0 ]
}

@test "a tweak shows its script first and closes with one button" {
    mkdir -p "${d2}/tweaks" "$game"
    printf '#!/usr/bin/env bash\n# Fails.\necho "no luck"\nexit 3\n' >"${d2}/tweaks/broken.sh"
    answer 0 Tweaks
    answer 0 broken
    answer 1
    answer 0 broken
    answer 0
    run "${app}/d2launcher"
    [ "$status" -eq 0 ]
    run grep -c -- '--text-info --title=broken .* --ok-label=Install --cancel-label=Back$' "${STUB}/calls"
    [ "$output" -eq 2 ]
    grep -q -- '--error --width=360 --text=broken failed with status 3.\\n\\n<tt>no luck</tt>' "${STUB}/calls"
    run grep -o -- '--column=[A-Za-z]*' "${STUB}/calls"
    [ "${lines[*]}" = '--column=Menu --column=Tweaks --column= --column=Tweaks --column= --column=Tweaks --column= --column=Menu' ]
}

@test "Choose Version marks the installed version" {
    installed 2.14.6
    mkdir -p "${d2}/patches"
    touch "${d2}/patches/"{2.14.5,2.14.6}.sha1
    run launcher choose_version
    [ "$status" -eq 0 ]
    grep -q -- '--column=Choose Version --column= --ok-label=Install --cancel-label=Back TRUE 2.14.6 installed FALSE 2.14.5 $' "${STUB}/calls"
}
