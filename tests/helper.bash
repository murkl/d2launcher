# The launcher as a copy unpacked by hand, with a home of its own and the stubs
# first on the PATH. Nothing of the machine it runs on is read or written.
setup_launcher() {
    export HOME="${BATS_TEST_TMPDIR}/home"
    export XDG_CACHE_HOME="${BATS_TEST_TMPDIR}/cache" XDG_DATA_HOME="${BATS_TEST_TMPDIR}/data"
    export STUB="${BATS_TEST_TMPDIR}/stub" USER=player
    # The bundled Wine of the tests reports the version the launcher pins.
    STUB_WINE_VERSION="$(sed -n "s/^WINE_VERSION='\(.*\)'$/\1/p" "${BATS_TEST_DIRNAME}/../d2launcher")"
    export STUB_WINE_VERSION
    export PATH="${BATS_TEST_DIRNAME}/stub:${PATH}"
    app="${BATS_TEST_TMPDIR}/app"
    d2="${HOME}/.d2launcher"
    mkdir -p "$HOME" "${STUB}/web" "$app"
    cp -r "${BATS_TEST_DIRNAME}"/../{d2launcher,d2launcher.desktop,d2launcher.svg,tweaks} "$app/"
}

# Runs bash code against the launcher's functions as main sets them up: strict,
# in a shell of its own, with the settings at their defaults.
launcher() {
    bash -c 'source "$1"
        strict
        places
        defaults
        icon_option=()
        mkdir -p "$home" "$backups" "$cache" "$logs"
        run="$(mktemp -d -p "$cache")"
        eval "$2"' _ "${app}/d2launcher" "$1"
}

# The answer to the next dialog that needs one: its status and what it prints.
answer() {
    printf '%s\t%s\n' "$1" "${2:-}" >>"${STUB}/answers"
}

# What the stubbed web answers for a URL, read from stdin.
serve() {
    local sum
    sum="$(printf '%s' "$1" | sha1sum)"
    cat >"${STUB}/web/${sum%% *}"
}

# The bundled Wine, as the stub.
fake_wine() {
    mkdir -p "${d2}/bin/wine/bin"
    ln -s "${BATS_TEST_DIRNAME}/stub/wine" "${d2}/bin/wine/bin/wine"
}

# A program first on the PATH, in place of the real one or its stub: the bash code given.
replace_program() {
    mkdir -p "${BATS_TEST_TMPDIR}/bin"
    printf '#!/usr/bin/env bash\n%s\n' "$2" >"${BATS_TEST_TMPDIR}/bin/$1"
    chmod +x "${BATS_TEST_TMPDIR}/bin/$1"
    export PATH="${BATS_TEST_TMPDIR}/bin:${PATH}"
}

# The Wine the launcher of the tests pins, in its file, as a job reads it from there.
pin_wine() {
    sed -i -e "s|^WINE_URL=.*|WINE_URL='$1'|" -e "s|^WINE_SHA256=.*|WINE_SHA256='$2'|" \
        -e "s|^WINE_VERSION=.*|WINE_VERSION='$3'|" "${app}/d2launcher"
}

# A Median XL version on the stubbed server: a file per argument, name=content.
publish_mxl() {
    local tag="$1" item name files='[]' sum
    shift
    for item; do
        name="${item%%=*}"
        printf '%s' "${item#*=}" | serve "https://get.example/${tag}/${name}"
        sum="$(printf '%s' "${item#*=}" | sha1sum)"
        files="$(jq -c --arg n "$name" --arg s "${sum%% *}" --arg u "https://get.example/${tag}/${name}" \
            '. + [{name: $n, sha1: $s, url: $u}]' <<<"$files")"
    done
    jq -n --arg t "$tag" --argjson f "$files" '{tag: $t, files: $f}' |
        serve 'https://launcher.median-xl.com/mxl/release/public/manifest'
}
