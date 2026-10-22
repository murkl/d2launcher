#!/usr/bin/env bats
# shellcheck disable=SC2016  # launcher runs the code it is given, in a shell of its own

setup() {
    # shellcheck source=tests/helper.bash
    source "${BATS_TEST_DIRNAME}/helper.bash"
    setup_launcher
    game="${d2}/bin/diablo2"
    mkdir -p "$game"
}

sum() {
    printf '%s' "$1" | sha1sum | cut -c1-40
}

@test "an update downloads only what the store lacks" {
    publish_mxl 1.0 a.mpq=alpha b.dll=beta
    run launcher 'fetch_manifest && store_version 1.0 && install_version 1.0'
    [ "$status" -eq 0 ]
    [ "$(cat "${game}/a.mpq")" = alpha ]
    [ "$(cat "${game}/d2launcher-patch.version")" = 1.0 ]
    publish_mxl 1.1 a.mpq=alpha b.dll=gamma
    : >"${STUB}/requests"
    run launcher 'fetch_manifest && store_version 1.1'
    [ "$status" -eq 0 ]
    run grep -c '^https://get.example/' "${STUB}/requests"
    [ "$output" -eq 1 ]
}

@test "a file the game holds already is taken from there" {
    printf 'alpha' >"${game}/a.mpq"
    publish_mxl 1.0 a.mpq=alpha
    run launcher 'fetch_manifest && store_version 1.0'
    [ "$status" -eq 0 ]
    run grep -c '^https://get.example/' "${STUB}/requests"
    [ "$output" -eq 0 ]
    [ "$(cat "${d2}/patches/files/$(sum alpha)")" = alpha ]
}

@test "a download that does not match its sha1 stays out of the store" {
    publish_mxl 1.0 a.mpq=alpha
    printf 'tampered' | serve https://get.example/1.0/a.mpq
    run launcher 'fetch_manifest && store_version 1.0'
    [ "$status" -ne 0 ]
    [ ! -e "${d2}/patches/files/$(sum alpha)" ]
    [ ! -e "${d2}/patches/1.0.sha1" ]
}

@test "a manifest that names a path is refused" {
    jq -n --arg s "$(sum x)" '{tag: "1.0", files: [{name: "../evil.dll", sha1: $s, url: "https://get.example/x"}]}' |
        serve https://launcher.median-xl.com/mxl/release/public/manifest
    run launcher fetch_manifest
    [ "$status" -ne 0 ]
    jq -n '{tag: "null", files: []}' | serve https://launcher.median-xl.com/mxl/release/public/manifest
    run launcher fetch_manifest
    [ "$status" -ne 0 ]
}

@test "a file you changed stays, unless you replace it, and what a version drops goes" {
    publish_mxl 1.0 ddraw.dll=mxl old.mpq=old
    launcher 'fetch_manifest && store_version 1.0 && install_version 1.0'
    printf 'mine' >"${game}/ddraw.dll"
    publish_mxl 1.1 ddraw.dll=mxl-2 new.mpq=new
    answer 0
    run launcher 'fetch_manifest && store_version 1.1 && apply_version 1.1'
    [ "$status" -eq 0 ]
    [ "$(cat "${game}/ddraw.dll")" = mine ]
    [ "$(cat "${game}/new.mpq")" = new ]
    [ ! -e "${game}/old.mpq" ]
    grep -q 'You changed these files since Median XL 1.0' "${STUB}/calls"
    answer 1 Replace
    run launcher 'apply_version 1.1'
    [ "$status" -eq 0 ]
    [ "$(cat "${game}/ddraw.dll")" = mxl-2 ]
}

@test "Cancel at the question leaves the game as it is" {
    publish_mxl 1.0 ddraw.dll=mxl
    launcher 'fetch_manifest && store_version 1.0 && install_version 1.0'
    printf 'mine' >"${game}/ddraw.dll"
    publish_mxl 1.1 ddraw.dll=mxl-2
    answer 1
    run launcher 'fetch_manifest && store_version 1.1 && apply_version 1.1'
    [ "$status" -ne 0 ]
    [ "$(cat "${game}/ddraw.dll")" = mine ]
    [ "$(cat "${game}/d2launcher-patch.version")" = 1.0 ]
}

@test "4.x zips move into the store, and the installed version gets its list" {
    mkdir -p "${d2}/patches" "${BATS_TEST_TMPDIR}/zip"
    printf 'alpha' >"${BATS_TEST_TMPDIR}/zip/a.mpq"
    printf 'beta' >"${BATS_TEST_TMPDIR}/zip/b dll.dll"
    (cd "${BATS_TEST_TMPDIR}/zip" && zip -q0 "${d2}/patches/d2launcher-mxl-2.14.6.zip" a.mpq 'b dll.dll')
    echo d2launcher-mxl-2.14.6 >"${game}/d2launcher-patch.version"
    run launcher migrate_patches
    [ "$status" -eq 0 ]
    [ ! -e "${d2}/patches/d2launcher-mxl-2.14.6.zip" ]
    [ "$(cat "${d2}/patches/files/$(sum beta)")" = beta ]
    printf '%s  %s\n' "$(sum alpha)" a.mpq "$(sum beta)" 'b dll.dll' | cmp - "${d2}/patches/2.14.6.sha1"
    cmp "${d2}/patches/2.14.6.sha1" "${game}/d2launcher-patch.sha1"
    run launcher installed_tag
    [ "$output" = 2.14.6 ]
}

@test "the store keeps the three newest versions and the installed one" {
    local tag
    for tag in 1.0 1.1 1.2 1.3 1.4; do
        publish_mxl "$tag" "v.mpq=${tag}"
        launcher "fetch_manifest && store_version ${tag}"
    done
    launcher 'install_version 1.0 && prune_store'
    run launcher versions
    [ "${lines[*]}" = '1.4 1.3 1.2 1.0' ]
    [ ! -e "${d2}/patches/files/$(sum 1.1)" ]
    [ -e "${d2}/patches/files/$(sum 1.0)" ]
}
