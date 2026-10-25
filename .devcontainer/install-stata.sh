#!/usr/bin/env bash
# Installs Stata into /usr/local/stata19 (a named volume) from the host files
# mounted at /opt/stata-host. Idempotent: skips the install once the .installed
# marker exists, so the volume survives container rebuilds.
set -euo pipefail

src=/opt/stata-host
dest=/usr/local/stata19

sudo chown "$(id -u):$(id -g)" "$dest"

if [ -e "$dest/.installed" ]; then
    echo "Stata already installed in $dest"
else
    tarball=$(find "$src" -maxdepth 1 -name '*.tar.gz' | head -n1)
    if [ -z "$tarball" ]; then
        # Not a failure: the container is still useful, and failing here would
        # fail the whole postCreateCommand. Put the files on the host and run
        # this script again.
        echo "SKIP: no Stata *.tar.gz in ~/.config/stata on the host; Stata is not installed." >&2
        echo "      Add the tarball and stata.lic there, then run .devcontainer/install-stata.sh" >&2
        exit 0
    fi
    echo "Installing Stata from $(basename "$tarball")"
    tmp=$(mktemp -d)
    tar -xzf "$tarball" -C "$tmp"
    # yes dies of SIGPIPE when install exits; that is not a failure.
    (cd "$dest" && { yes || true; } | "$tmp/install")
    rm -rf "$tmp"
    touch "$dest/.installed"
fi

if [ ! -f "$src/stata.lic" ]; then
    echo "SKIP: no stata.lic in ~/.config/stata on the host; cannot run Stata yet." >&2
    exit 0
fi
ln -sf "$src/stata.lic" "$dest/stata.lic"

# Smoke test: which edition runs, and does the license work?
for b in stata-mp stata-se stata; do
    if [ -x "$dest/$b" ]; then
        cd "$(mktemp -d)"
        echo 'display "stata_ok " c(stata_version)' > smoke.do
        "$b" -q -b do smoke.do || true
        if grep -q '^stata_ok' smoke.log 2>/dev/null; then
            echo "Stata OK: $b $(grep '^stata_ok' smoke.log | cut -d' ' -f2)"
            exit 0
        fi
        echo "ERROR: $b did not run. Log follows:" >&2
        cat smoke.log >&2 2>/dev/null || true
        exit 1
    fi
done
echo "ERROR: no stata binary in $dest after install" >&2
exit 1
