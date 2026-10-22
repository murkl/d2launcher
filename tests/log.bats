#!/usr/bin/env bats
# shellcheck disable=SC2016  # launcher runs the code it is given, in a shell of its own

setup() {
    # shellcheck source=tests/helper.bash
    source "${BATS_TEST_DIRNAME}/helper.bash"
    setup_launcher
}

@test "a log line holds the time, its source and what happened" {
    run launcher 'log "hello" && printf "first\nsecond\n" | log_stream wine && cat "$logfile"'
    [ "$status" -eq 0 ]
    [[ ${lines[0]} =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}\ [0-9]{2}:[0-9]{2}:[0-9]{2}\ \ launcher\ \ hello$ ]]
    [[ ${lines[1]} =~ ^[0-9-]{10}\ [0-9:]{8}\ \ wine\ {6}first$ ]]
    [[ ${lines[2]} == *'  wine      second' ]]
}

@test "a job logs its start, its errors and how it ended" {
    run launcher 'ui_progress Testing bash -c "echo broken >&2; exit 3" || true; cat "$logfile"'
    [[ ${lines[0]} == *'  launcher  Testing: started' ]]
    [[ ${lines[1]} == *'  launcher  broken' ]]
    [[ ${lines[2]} == *'  launcher  Testing: failed with status 3' ]]
}

@test "each start writes a log of its own, and the four before stay" {
    local _
    for _ in {1..6}; do
        run "${app}/d2launcher"
        [ "$status" -eq 0 ]
    done
    run ls "${d2}/logs"
    [ "${lines[*]}" = 'd2launcher.log d2launcher.log.1 d2launcher.log.2 d2launcher.log.3 d2launcher.log.4' ]
    grep -q '  launcher  D2Launcher unknown on ' "${d2}/logs/d2launcher.log"
    grep -q '  launcher  Menu: Exit' "${d2}/logs/d2launcher.log.4"
}

@test "the logs of 4.x join the rotation" {
    mkdir -p "${d2}/backup"
    echo older >"${d2}/backup/d2launcher.log.old"
    echo old >"${d2}/d2launcher.log"
    run "${app}/d2launcher"
    [ "$status" -eq 0 ]
    [ "$(cat "${d2}/logs/d2launcher.log.1")" = old ]
    [ "$(cat "${d2}/logs/d2launcher.log.2")" = older ]
    [ ! -e "${d2}/d2launcher.log" ]
    [ ! -e "${d2}/backup/d2launcher.log.old" ]
}

@test "what a tweak prints is in its window and in the log" {
    mkdir -p "${d2}/tweaks" "${d2}/bin/diablo2"
    printf '#!/usr/bin/env bash\n# Says hello.\necho "hello from ${D2_DIR##*/}"\n' >"${d2}/tweaks/hello.sh"
    answer 0 Tweaks
    answer 0 hello
    answer 0
    run "${app}/d2launcher"
    [ "$status" -eq 0 ]
    grep -q '  tweak     hello from diablo2' "${d2}/logs/d2launcher.log"
    grep -q 'text-info --title=hello' "${STUB}/calls"
}
