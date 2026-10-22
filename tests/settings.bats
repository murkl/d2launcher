#!/usr/bin/env bats
# shellcheck disable=SC2016  # launcher runs the code it is given, in a shell of its own

setup() {
    # shellcheck source=tests/helper.bash
    source "${BATS_TEST_DIRNAME}/helper.bash"
    setup_launcher
}

@test "a first start writes every setting at its default" {
    run launcher 'load_settings && printf "%s|%s|%s|%s|%s|%s\n" "$launch_options" "$channel" "$wine" "$prefix" "$median_xl" "$d2stats"'
    [ "$status" -eq 0 ]
    [ "$output" = "-3dfx|public|${d2}/bin/wine/bin/wine|${d2}/wineprefix|true|false" ]
    run grep -Ev '^(#|$)' "${d2}/d2launcher.conf"
    [ "${lines[*]}" = 'launch_options=-3dfx channel=public wine= prefix=~/.d2launcher/wineprefix median_xl=true d2stats=false' ]
}

@test "a setting takes quotes and ~ as a shell would write them" {
    mkdir -p "$d2"
    printf '%s\n' 'launch_options="gamemoderun %command% -ddraw"' 'channel=beta' 'prefix=~/prefix  ' >"${d2}/d2launcher.conf"
    run launcher 'read_settings "$conf" && printf "%s|%s|%s\n" "$launch_options" "$channel" "$prefix"'
    [ "$status" -eq 0 ]
    [ "$output" = "gamemoderun %command% -ddraw|beta|${HOME}/prefix" ]
}

@test "a mistake names its line and the rule it breaks" {
    local line rule
    while IFS='|' read -r line rule; do
        printf '# settings\n%s\n' "$line" >"${BATS_TEST_TMPDIR}/conf"
        run launcher "read_settings ${BATS_TEST_TMPDIR}/conf"
        [ "$status" -eq 1 ]
        [[ $output == "Line 2"*"$rule"* ]]
    done <<'EOF'
export PULSE_LATENCY_MSEC=120| is no setting=value
d2_args=-3dfx|there is no setting d2_args
channel=alpha|channel is public or beta
d2stats=yes|d2stats is true or false
median_xl=no|median_xl is true or false
launch_options=no-such-wrapper %command% -3dfx|launch_options runs no-such-wrapper, which is not installed
launch_options=gamemoderun %command%; rm x|launch_options runs without a shell
launch_options=$(id) %command%|launch_options runs without a shell
wine=/no/such/wine|wine names no program
prefix=games/diablo2|prefix is an absolute path
EOF
}

@test "a program in front of %command% has to be installed, variables and arguments not" {
    local value
    for value in 'PULSE_LATENCY_MSEC=60 %command% -3dfx' 'gamemoderun %command%' '-3dfx no-such-program'; do
        printf 'launch_options=%s\n' "$value" >"${BATS_TEST_TMPDIR}/conf"
        run launcher "read_settings ${BATS_TEST_TMPDIR}/conf"
        [ "$status" -eq 0 ]
    done
}

@test "d2stats needs Median XL" {
    printf 'd2stats=true\nmedian_xl=false\n' >"${BATS_TEST_TMPDIR}/conf"
    run launcher "read_settings ${BATS_TEST_TMPDIR}/conf"
    [ "$status" -eq 1 ]
    [ "$output" = 'd2stats reads Median XL and needs median_xl=true.' ]
}

@test "launch options wrap the game as in Steam" {
    fake_wine
    mkdir -p "${d2}/bin/diablo2"
    run launcher 'launch_options="PULSE_LATENCY_MSEC=120 env %command% -3dfx -w" && launch "Diablo II.exe"'
    [ "$status" -eq 0 ]
    run cat "${STUB}/wine"
    [ "${lines[0]}" = "cwd=${d2}/bin/diablo2" ]
    [ "${lines[1]}" = "env=WINEPREFIX=${d2}/wineprefix WINEDEBUG=fixme-all WINEDLLOVERRIDES=ddraw=n,b;winemenubuilder.exe=d WINEARCH=unset PULSE_LATENCY_MSEC=120" ]
    [ "${lines[*]:2}" = 'arg=Diablo II.exe arg=-3dfx arg=-w' ]
}

@test "launch options without %command% are the game's arguments" {
    fake_wine
    mkdir -p "${d2}/bin/diablo2"
    run launcher 'launch_options="-ddraw -ns" && launch sigma-loader.exe'
    [ "$status" -eq 0 ]
    run grep '^arg=' "${STUB}/wine"
    [ "${lines[*]}" = 'arg=sigma-loader.exe arg=-ddraw arg=-ns' ]
}

@test "4.x settings take the new form, and the old file stays beside it" {
    mkdir -p "$d2"
    cp "${BATS_TEST_DIRNAME}/fixtures/d2launcher-4.conf" "${d2}/d2launcher.conf"
    run launcher migrate_settings
    [ "$status" -eq 0 ]
    cmp "${BATS_TEST_DIRNAME}/fixtures/d2launcher-4.conf" "${d2}/d2launcher.conf.bak"
    run grep -Ev '^(#|$)' "${d2}/d2launcher.conf"
    [ "${lines[*]}" = 'launch_options=PULSE_LATENCY_MSEC=120 gamemoderun %command% -3dfx -log -dxnocompatmodefix channel=public wine= prefix=~/.d2launcher/wineprefix median_xl=true d2stats=false' ]
    cp "${d2}/d2launcher.conf" "${BATS_TEST_TMPDIR}/migrated"
    run launcher 'migrate_settings && load_settings'
    [ "$status" -eq 0 ]
    cmp "${BATS_TEST_TMPDIR}/migrated" "${d2}/d2launcher.conf"
}

@test "custom_command of 4.x takes the game's command line" {
    mkdir -p "$d2"
    printf '%s\n' 'd2_args="-3dfx"' 'custom_command="lutris lutris:rungame/diablo-2"' 'mxl_update_channel="beta"' \
        >"${d2}/d2launcher.conf"
    run launcher migrate_settings
    [ "$status" -eq 0 ]
    run grep -Ev '^(#|$)' "${d2}/d2launcher.conf"
    [ "${lines[*]}" = 'launch_options=lutris lutris:rungame/diablo-2 %command% channel=beta wine= prefix=~/.d2launcher/wineprefix median_xl=true d2stats=false' ]
}

@test "a 4.x start between new ones appends its defaults, which go without a second migration" {
    mkdir -p "$d2"
    cp "${BATS_TEST_DIRNAME}/fixtures/d2launcher-4.conf" "${d2}/d2launcher.conf"
    launcher migrate_settings
    cp "${d2}/d2launcher.conf" "${BATS_TEST_TMPDIR}/migrated"
    printf '%s\n' 'd2_exe="Diablo II.exe"' 'd2_args="-3dfx"' 'gui_width="450"' 'update_check="true"' >>"${d2}/d2launcher.conf"
    run launcher 'migrate_settings && load_settings && echo "$launch_options"'
    [ "$status" -eq 0 ]
    [ "${lines[-1]}" = 'PULSE_LATENCY_MSEC=120 gamemoderun %command% -3dfx -log -dxnocompatmodefix' ]
    cmp "${BATS_TEST_TMPDIR}/migrated" "${d2}/d2launcher.conf"
    cmp "${BATS_TEST_DIRNAME}/fixtures/d2launcher-4.conf" "${d2}/d2launcher.conf.bak"
}
