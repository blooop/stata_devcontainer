# stata_devcontainer

A devcontainer that runs Stata 19 (BE, SE or MP) on Ubuntu 24.04: the console,
batch mode, and the `xstata` GUI.

This repo contains no Stata files. You bring your own installer and license;
the container installs Stata from them on first start.

## Requirements

- Linux x86-64 host with Docker.
- A devcontainer client: VS Code Dev Containers, the `devcontainer` CLI, or DevPod.
- A Stata 19 license and the Linux 64-bit installer tarball from your
  stata.com account.

## Setup

Put two files in `~/.config/stata/` on the host:

```
~/.config/stata/
├── Stata19Linux64.tar.gz   # any *.tar.gz name works (StataNow too)
└── stata.lic               # from an existing install, or written by stinit
```

To get `stata.lic` without an existing install, extract the tarball
somewhere, run its `install` script into an empty folder, then run
`sudo ./stinit` there and enter your serial number, code and authorization.

Then start the container:

```sh
git clone https://github.com/blooop/stata_devcontainer
devcontainer up --workspace-folder stata_devcontainer
# or: devpod up ./stata_devcontainer
# or: open the folder in VS Code and choose "Reopen in Container"
```

On first start, `install-stata.sh` installs Stata into the `stata19` Docker
volume and prints `Stata OK: stata-mp 19.x` (or `stata-se` / `stata`). Later
containers reuse the volume and start in seconds. To reinstall, for example
after a Stata update: `docker volume rm stata19`.

## Use

- Console: `stata-mp` (or `stata-se`, `stata`, depending on your license).
- Batch: `stata-mp -b do analysis.do` writes `analysis.log` in the current folder.
- GUI: `xstata-mp`. It draws on the host display through `/tmp/.X11-unix`,
  so it works under X11 and under Wayland (via XWayland).

## Using it with a coding agent

See [AGENTS.md](AGENTS.md). Claude Code, Codex and similar agents read it
automatically when started in this folder.

## Notes

- Ubuntu dropped `libtinfo5`/`libncurses5`; the image links the `.so.5` names
  to the `.so.6` libraries, which Stata's console binaries need.
- The license and tarball are mounted read-only and never copied into the
  image, so the image is safe to share. The `stata19` volume does contain
  Stata; treat it like any local install.
