# Contributing

Every change comes back to `main` as one squash commit under its pull request title, in **[Conventional Commits](https://www.conventionalcommits.org)**: `fix:` releases a patch, `feat:` a minor and `feat!:` a major version.

## Commands

```
make check        # the gate CI runs
make run          # the launcher against a throwaway home in target/
make distro-check # the included Wine on Arch, Debian, Ubuntu, Fedora and openSUSE, in docker
make banner       # docs/banner.png out of the launcher's windows, in docker
```

```
sudo pacman -S --needed docker $(make -s packages)
```

## Rules

- `d2launcher` is one file and runs as it is, from a checkout too. A release stamps its version
- Every request leaving the machine goes through `fetch`, bound to https
- Every Wine call goes through `with_wine`, every line of output through `log`
- A change comes with its test in `tests/`, where zenity, Wine and the web are stubs
- The included Wine is pinned with its sha256 and version. After a change of it, of `aur/PKGBUILD` or of the lines in REFERENCE.md, `make distro-check` runs. CI runs it monthly

## Releasing

Merging the pull request `chore: release x.y.z` tags the version, publishes the release with the tarball of `make dist` and pushes the AUR package. The workflow's own token writes that pull request and reports the checks `main` passed on it. The push to the AUR needs the secret `AUR_SSH_KEY` from `tools/aur.sh key`, which only `main` may use. Its public half goes into the AUR account.

A Publish that failed runs again with **Re-run failed jobs** on its run.

`make github` applies `.github/settings/` to the repository. It lets workflows open pull requests, for the release pull request.

**Note:** _The social preview is `docs/banner.png`, uploaded by hand under **Settings › General › Social preview**: GitHub has no API for it._
