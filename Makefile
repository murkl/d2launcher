# Recipes are bash and stop at the first failing command, in pipes too.
SHELL       := bash
.SHELLFLAGS := -eu -o pipefail -c

# The date names the base, the digest pins it. CI runs in the same, as make lint checks.
IMAGE := archlinux:base-devel-20261011.0.609700@sha256:061679925e5d5028f2df9395d441ce6c4b9accf0157ff3486c06b6962e014ef1

# What make check needs. CI installs them. mutter and zenity draw a real window
# for tests/desktop.bats.
PACKAGES := shellcheck shfmt bats actionlint zizmor yamllint namcap desktop-file-utils jq zip unzip git mutter zenity

# A release's version, set by CI. Every other build is a pre-release of the next
# patch, as the launcher reports it from a checkout.
VERSION ?= $(shell ./d2launcher --version)

# The distributions docs/README.md names, and Arch. The digest pins each image.
DISTROS := \
	arch=$(IMAGE) \
	debian=debian:13@sha256:4c25275446ca371766b8b093c696782eabce06263fccacb8d5d813b3dc44b308 \
	ubuntu=ubuntu:24.04@sha256:68ee22004a9109b44973313b02ff7b1de250f1de0f5ecb628d73f579aaff33ac \
	fedora=fedora:43@sha256:a651ddf48ea28a06ed4e1e6519f51c9f47e7a5a138722ade87369b8fbb7e5b42 \
	opensuse=opensuse/tumbleweed@sha256:7df48ea164732cdebac69081179bcbed85b0573247f14846993e0ee3938f0e9c

# What make banner needs, in its container.
BANNER_PACKAGES := chromium otf-cormorant xorg-server-xvfb imagemagick pngquant zenity adwaita-fonts librsvg jq

# The shell code. d2launcher and the stubs carry no extension, so the lint names them.
SCRIPTS := d2launcher tweaks/*.sh tools/*.sh tests/stub/* docs/*.sh .github/*.sh

.PHONY: all check lint test dist aur-check distro-check run banner packages github clean

all: check

# The one command that has to pass before a commit.
check: lint test aur-check

lint:
	shellcheck $(SCRIPTS) tests/*.bats tests/helper.bash
	shfmt -d $(SCRIPTS)
	desktop-file-validate d2launcher.desktop
	yamllint -s .
	actionlint
	zizmor --offline --quiet .github/workflows
	[ "$$(sed -n 's/^ *container: //p' .github/workflows/ci.yml | sort -u)" = '$(IMAGE)' ]

test:
	bats tests

# What a release ships, as target/d2launcher-$(VERSION).tar.gz: the launcher with
# its version stamped and read back, its menu entry, icon, tweaks and license.
# Owner and times come from no one's machine, so a rerun writes the same bytes.
dist:
	rm -rf target/dist
	mkdir -p target/dist/d2launcher-$(VERSION)
	cp -r d2launcher d2launcher.desktop d2launcher.svg tweaks LICENSE target/dist/d2launcher-$(VERSION)/
	sed -i "s/^VERSION='{{VERSION}}'$$/VERSION='$(VERSION)'/" target/dist/d2launcher-$(VERSION)/d2launcher
	[ "$$(target/dist/d2launcher-$(VERSION)/d2launcher --version)" = "$(VERSION)" ]
	tar --sort=name --mtime=@$$(git -c safe.directory='$(CURDIR)' log -1 --format=%ct) \
		--owner=0 --group=0 --numeric-owner -C target/dist -cf - d2launcher-$(VERSION) | \
		gzip -9n >target/d2launcher-$(VERSION).tar.gz

# The package as a user builds it, for a stand-in version.
aur-check:
	$(MAKE) --no-print-directory dist VERSION=0.0.0
	rm -rf target/aur
	tools/aur.sh stamp 0.0.0 target/d2launcher-0.0.0.tar.gz target/aur
	tools/aur.sh build target/aur

# D2Launcher's Wine on each distribution, with what the project names for it.
distro-check:
	for distro in $(DISTROS); do \
		docker run --rm -v "$(CURDIR):/repo:ro" -w /repo "$${distro#*=}" tools/distro-check.sh "$${distro%%=*}"; \
	done

# The launcher against a home in target/, so nothing of yours changes.
run:
	mkdir -p target/home
	HOME="$(CURDIR)/target/home" XDG_CACHE_HOME="$(CURDIR)/target/home/.cache" \
		XDG_DATA_HOME="$(CURDIR)/target/home/.local/share" ./d2launcher

# docs/banner.png out of the launcher's windows, in a throwaway Arch. VERSION is
# what they show, so the next release can be pictured before it exists.
banner:
	docker run --rm -v "$(CURDIR):/repo" -w /repo $(IMAGE) bash -c \
		'pacman -Syu --noconfirm --needed $(BANNER_PACKAGES) >/dev/null && docs/banner.sh "$(VERSION)"; \
		status=$$?; chown -R $(shell id -u):$(shell id -g) target docs/banner.png; exit $$status'

packages:
	@echo $(PACKAGES)

# The repository's settings on GitHub, out of .github/settings/. Run by hand as
# an admin: a workflow may not change the rules it is held to.
github:
	.github/settings.sh

clean:
	rm -rf target
