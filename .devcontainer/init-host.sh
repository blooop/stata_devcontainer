#!/usr/bin/env bash
# Runs on the host before the container starts.
#
# It never fails. A missing tarball or license used to exit 1 here, and a
# failing initializeCommand stops the container before it exists: no shell, no
# way to look around, and under `dl` only a bare error. Now the directory is
# created so the bind mount has a source, the missing files are named, and
# install-stata.sh skips the install until they are there.
set -u
dir="$HOME/.config/stata"
mkdir -p "$dir"
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
