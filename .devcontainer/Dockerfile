FROM mcr.microsoft.com/devcontainers/base:ubuntu-24.04

ARG PIXI_VERSION=v0.65.0

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

RUN curl -L -o /usr/local/bin/pixi -fsSL --compressed "https://github.com/prefix-dev/pixi/releases/download/${PIXI_VERSION}/pixi-$(uname -m)-unknown-linux-musl" \
    && chmod +x /usr/local/bin/pixi \
    && pixi info

# Stata itself is proprietary and never enters the image. install-stata.sh
# installs it on first start into the stata19 volume at /usr/local/stata19,
# from the tarball bind-mounted at /opt/stata-host. These links resolve once
# that has run.
RUN for b in stata stata-se stata-mp xstata xstata-se xstata-mp; do \
        ln -s /usr/local/stata19/$b /usr/local/bin/$b; \
    done

USER vscode
WORKDIR /home/vscode

RUN echo 'eval "$(pixi completion -s bash)"' >> /home/vscode/.bashrc \
    && echo 'export PATH="$HOME/.pixi/bin:$PATH"' >> /home/vscode/.profile \
    && mkdir -p /home/vscode/.ssh && chmod 700 /home/vscode/.ssh \
    && mkdir -p /home/vscode/.config/gh
