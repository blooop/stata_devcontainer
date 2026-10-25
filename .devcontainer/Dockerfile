# The shared base carries pixi, the claude-code feature, the vscode user and a
# CA bundle without emSign ECC Root CA - G3 (CVE-2026-111943). This file adds
# only what Stata needs on top of it.
FROM ghcr.io/blooop/python_template/devcontainer:latest

USER root

# Runtime libraries for Stata. The console binaries still link against the
# ncurses 5 ABI, which Ubuntu no longer ships, so point the .so.5 names at .so.6.
# libgtk-3 and the fonts are for the xstata GUI.
RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
    && apt-get install -y --no-install-recommends \
        libncurses6 libtinfo6 libgtk-3-0t64 libcanberra-gtk3-module \
        fonts-dejavu-core fontconfig \
    && ln -sf /lib/x86_64-linux-gnu/libtinfo.so.6 /lib/x86_64-linux-gnu/libtinfo.so.5 \
    && ln -sf /lib/x86_64-linux-gnu/libncurses.so.6 /lib/x86_64-linux-gnu/libncurses.so.5 \
    && ldconfig \
    && rm -rf /var/lib/apt/lists/*

# Stata itself is proprietary and never enters the image. install-stata.sh
# installs it on first start into the stata19 volume at /usr/local/stata19,
# from the tarball bind-mounted at /opt/stata-host. These links resolve once
# that has run.
RUN for b in stata stata-se stata-mp xstata xstata-se xstata-mp; do \
        ln -s /usr/local/stata19/$b /usr/local/bin/$b; \
    done

USER vscode
WORKDIR /home/vscode

# devcontainer.json bind-mounts the host's ~/.ssh here.
RUN mkdir -p /home/vscode/.ssh && chmod 700 /home/vscode/.ssh
