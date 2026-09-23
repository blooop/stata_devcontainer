#!/usr/bin/env bash
# Runs on the host before the container starts.
set -u
dir="$HOME/.config/stata"
ok=1
if ! compgen -G "$dir/*.tar.gz" >/dev/null; then
    echo "ERROR: no Stata Linux tarball in $dir (download it from your stata.com account)." >&2
    ok=0
fi
if [ ! -f "$dir/stata.lic" ]; then
    echo "ERROR: $dir/stata.lic not found (copy it from an existing Stata install)." >&2
    ok=0
fi
[ "$ok" = 1 ] || exit 1
# Allow local containers running as this uid to open GUI windows
# (X11, or XWayland under a Wayland session).
if [ -n "${DISPLAY:-}" ] && command -v xhost >/dev/null; then
    xhost "+SI:localuser:$(id -un)" >/dev/null 2>&1 || true
fi
