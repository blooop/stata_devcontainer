# Stata devcontainer

This container runs Stata 19. Stata lives in `/usr/local/stata19` and its binaries are on `PATH`. The repo itself holds no Stata files: the installer tarball and `stata.lic` stay in `~/.config/stata/` on the host, mounted read-only at `/opt/stata-host`.

If `stata-mp`, `stata-se` and `stata` all fail with "No such file", Stata is not installed yet: run `.devcontainer/install-stata.sh` and read its output. Setup from scratch is in `README.md`.

## Which binary

The license decides the edition. `.devcontainer/install-stata.sh` prints `Stata OK: <binary> <version>` on success; use that binary. Prefer `stata-mp`, then `stata-se`, then `stata` — only the one matching the license runs.

## Running Stata

Run Stata in **batch mode**. The console is interactive and the GUI needs a human.

1. Write the work as a do-file in the workspace, so it persists and the user can read it.
2. Run it from the folder where the log should land:

   ```sh
   stata-mp -q -b do analysis.do
   ```

   Stata writes `analysis.log` next to where you ran it. Nothing useful goes to stdout.
3. Read the log. The run is **done** only when the log has no error line. A Stata error is a line `r(NNN);` right after the failing command, and Stata stops the do-file there. Check with `grep -n '^r([0-9]*);' analysis.log`. Treat the exit status as unreliable: read the log every run.

For a one-off expression, a two-line do-file is still the way: `echo 'display 2+2' > t.do && stata-mp -q -b do t.do && cat t.log`.

## From the host

When you are outside the container, send the same command in. It runs in the workspace folder, so the do-file must be in that workspace's clone.

- devlaunch: `dl blooop/stata_devcontainer -- stata-mp -q -b do analysis.do`
- devcontainer CLI: `devcontainer exec --workspace-folder <clone> bash -lc 'cd /workspaces/<clone-name> && stata-mp -q -b do analysis.do'`

The workspace path differs by client (devlaunch uses `/workspaces/<workspace-id>`); inside the container, `pwd` in a fresh shell names it.

## Guardrails

- Keep the tarball and `stata.lic` in `~/.config/stata/` on the host. They are proprietary: never copy them into the repo, a commit, the image, or a log you share.
- Leave `/usr/local/stata19` to `install-stata.sh`. To reinstall, the user runs `docker volume rm stata19` on the host.
- License errors show in the log (for example "License not found" or an expired date). Report them to the user; the fix is a new `stata.lic`, which only they can supply.
