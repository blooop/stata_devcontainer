#!/usr/bin/env bash
# Runs on the host before the container starts.
#
# It never fails: a failing initializeCommand stops the container before it
# exists, with no shell to look around in. It creates the bind-mount sources and
# only warns about a missing tarball or license; install-stata.sh skips the
# install until they are there.
set -u
dir="$HOME/.config/stata"
mkdir -p "$dir"
# devcontainer.json bind-mounts ~/.ssh and ~/.config/gh, and the base image's
# devcontainer metadata bind-mounts ~/.claude. A bind mount with no source
# stops the container from starting, so create each one on a fresh host.
mkdir -p "$HOME/.claude" "$HOME/.config/gh"
if [ ! -d "$HOME/.ssh" ]; then
    mkdir -p "$HOME/.ssh" && chmod 700 "$HOME/.ssh"
fi
if ! compgen -G "$dir/*.tar.gz" >/dev/null; then
    echo "WARNING: no Stata Linux tarball in $dir (download it from your stata.com account). The container starts without Stata." >&2
fi
if [ ! -f "$dir/stata.lic" ]; then
    echo "WARNING: $dir/stata.lic not found (copy it from an existing Stata install). The container starts without a license." >&2
fi
# Allow local containers running as this uid to open GUI windows
# (X11, or XWayland under a Wayland session).
if [ -n "${DISPLAY:-}" ] && command -v xhost >/dev/null; then
    xhost "+SI:localuser:$(id -un)" >/dev/null 2>&1 || true
fi
exit 0
