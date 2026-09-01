# AGENTS.md

Instructions for coding agents (Claude Code, Codex, Cursor, etc.) working in
this repo.

## What this repo is

A small set of Bash scripts, a systemd user unit, and two config snippets
that fork [Omarchy](https://github.com/basecamp/omarchy)'s screensaver into a
single, continuous Matrix digital-rain effect, and add screen-blank and
AC/battery-aware sleep stages that stock Omarchy doesn't have. There is no
build step, no package manager, no test suite -- this *is* the deployed
artifact. `install.sh` copies these files onto a running Omarchy/Hyprland
system.

Read `README.md` first for the full behavior spec (timings, colors, why the
PATH-override trick in `hypr/local-bin-priority.lua` is necessary at all).

## Ground rules

- **Never target `/usr/share/omarchy`.** These scripts intentionally live in
  `~/.local/bin` / `~/.config/...` so they survive `omarchy update`. Don't
  suggest editing or symlinking over anything under `/usr/share/omarchy` --
  that defeats the entire point of the repo.
- **Bash, matching Omarchy's own style.** Look at the scripts already here
  (and, for reference, `/usr/bin/omarchy-*` on an Omarchy system) before
  adding a dependency or a different idiom. Plain POSIX-ish Bash, `jq` for
  JSON, `hyprctl` for compositor state -- no Python/Node/etc. added for a
  one-off task.
- **`bin/omarchy-idle-extender` polls, it doesn't guess.** It derives all
  state from `omarchy-shell idle status`, `omarchy-shell lock status`, and
  `omarchy-power-present` -- the same sources of truth Omarchy's own idle
  service uses -- rather than tracking input events itself. If you change its
  logic, keep it deriving state the same way; don't have it read raw input
  devices or duplicate Omarchy's own idle detection.
- **`SCREENSAVER_SECONDS` in `bin/omarchy-idle-extender` must stay equal to
  `idle.screensaver` in `shell/idle.json`.** It's how the daemon reconstructs
  when the idle period actually started, since Omarchy's own idle-cycle flag
  resets the moment the lock stage fires. If you change one, change the
  other and say so in the commit message.
- **ttfx flags are the whole UI.** There's no config file format of our own;
  tuning fall speed/density/color means editing the `ttfx ... matrix ...`
  invocation in `bin/omarchy-screensaver` directly. Run `ttfx matrix --help`
  before inventing a flag name.

## Testing changes

There's no CI and no simulator for this -- it only makes sense to verify on
a real Omarchy/Hyprland box.

- Syntax-check every script you touch: `bash -n bin/<script>`.
- Preview the screensaver without waiting for real idle:
  `omarchy-launch-screensaver force` (needs `bin/omarchy-screensaver`
  already installed via `install.sh`, or on `PATH` some other way). Dismiss
  with any key.
- Check the extender's live state without waiting out the real timers:
  `omarchy-shell idle status` and `omarchy-shell lock status` (both JSON).
- After editing `hypr/local-bin-priority.lua`, changes need `hyprctl reload`
  (not a full logout) to take effect on this Omarchy build -- but only for
  the *running* Hyprland process. Already-running processes like
  `omarchy-shell` need `omarchy restart shell` separately to pick up a
  changed `PATH`.
- After editing `systemd/omarchy-idle-extender.service`, reinstall it and
  run `systemctl --user daemon-reload && systemctl --user restart
  omarchy-idle-extender.service`.

## Commit style

Small, scoped commits with a plain-English summary of *behavior* change
(what a user would notice), not a diff narration. Match the existing log.
