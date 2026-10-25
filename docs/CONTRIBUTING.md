# Contributing

Every change comes back to `main` as one squash commit under its pull request title, in **[Conventional Commits](https://www.conventionalcommits.org)**, which sorts it into the release notes. Written as a short phrase a user understands, the notes show it from a capital: `fix: the launcher finds Wine on Fedora` becomes `* The launcher finds Wine on Fedora`.

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

A version tag on an up-to-date `main` releases. The run publishes the release with its notes and the tarball of `make dist`, then pushes the AUR package. The notes and their checks come from **[murkl/workflows](https://github.com/murkl/workflows)**, checked out next to this project:

```
../workflows/notes/notes.sh 4.2.0 && git tag 4.2.0 && git push origin 4.2.0
```

- `fix:` raises the patch, `feat:` the minor, `feat!:` the major version
- `AUR_SSH_KEY` from `tools/aur.sh key`, whose public half goes into the AUR account. Only version tags may use it
- A Publish that failed runs again with **Re-run failed jobs**. Tags never move, so a fix after a release is a new version

`make github` applies `.github/settings/` to the repository, with murkl/workflows checked out next to this project. `ruleset-tags.json` keeps every tag from being moved or deleted.

**Note:** _The social preview is `docs/banner.png`, uploaded by hand under **Settings › General › Social preview**: GitHub has no API for it._
