#!/usr/bin/env bats
# shellcheck disable=SC2016  # launcher runs the code it is given, in a shell of its own

# The real zenity in a headless mutter, which answers like GNOME's compositor.
setup() {
    # shellcheck source=tests/helper.bash
    source "${BATS_TEST_DIRNAME}/helper.bash"
    setup_launcher
    export PATH="${PATH#"${BATS_TEST_DIRNAME}/stub:"}"
    export XDG_RUNTIME_DIR="${BATS_TEST_TMPDIR}/runtime"
    mkdir -m 700 "$XDG_RUNTIME_DIR"
    dbus-run-session -- mutter --wayland --headless --no-x11 --virtual-monitor 800x600 --wayland-display=d2l \
        >"${BATS_TEST_TMPDIR}/mutter.log" 2>&1 3>&- &
    mutter=$!
    local _
    for _ in {1..100}; do
        [[ ! -S ${XDG_RUNTIME_DIR}/d2l ]] || return 0
        read -rt 0.1 <> <(:) || true
    done
    cat "${BATS_TEST_TMPDIR}/mutter.log" >&2
    return 1
}

teardown() {
    kill "$mutter" 2>/dev/null || true
}

# The app id a window asks the compositor for, while it shows for two seconds.
app_id() {
    WAYLAND_DISPLAY=d2l GDK_BACKEND=wayland WAYLAND_DEBUG=client timeout 2 "$@" 2>&1 |
        sed -n 's/.*set_app_id("\([^"]*\)").*/\1/p'
}

@test "the launcher's windows go by the name of its menu entry, other zenity windows by their own" {
    run app_id bash -c 'source "$1" && icon_option=() && ui --info --text=test' _ "${app}/d2launcher"
    [ "$output" = d2launcher ]
    grep -qx 'StartupWMClass=d2launcher' "${app}/d2launcher.desktop"
    run app_id zenity --info --text=test
    [ "$output" = zenity ]
}
