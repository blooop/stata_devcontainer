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
        echo "ERROR: no Stata *.tar.gz in ~/.config/stata on the host" >&2
        exit 1
    fi
    echo "Installing Stata from $(basename "$tarball")"
    tmp=$(mktemp -d)
    tar -xzf "$tarball" -C "$tmp"
    # yes dies of SIGPIPE when install exits; that is not a failure.
    (cd "$dest" && { yes || true; } | "$tmp/install")
    rm -rf "$tmp"
    touch "$dest/.installed"
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
