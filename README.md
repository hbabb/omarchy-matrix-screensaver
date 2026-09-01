# omarchy-matrix-screensaver

[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![Built for Omarchy](https://img.shields.io/badge/built%20for-Omarchy-1e1e2e.svg)](https://omarchy.org)

A fork of [Omarchy](https://github.com/basecamp/omarchy)'s screensaver system
that is *only* the Matrix digital-rain "waterfall," in the original movie
green, plus an idle/lock/blank/sleep timing setup to go with it:

- **10 min** idle &rarr; screensaver starts
- **+30 min** &rarr; lock screen (40 min total)
- **+15 min** &rarr; display blanks (DPMS off, 55 min total)
- **Plugged in:** stays locked + blanked, awake, until **5 hours** total
  inactivity, then suspends
- **On battery:** suspends immediately at the 55-minute mark instead of just
  blanking
- The bar's **Stay Awake** toggle and Hyprland's idle inhibitors (fullscreen
  games, video calls, etc.) are respected throughout

Stock Omarchy's screensaver cycles through ~30 random effects via
[`ttfx`](https://github.com/omacom-io/ttfx) and only handles the
screensaver+lock stages of idle. This repo narrows that down to one effect
and adds the blank/sleep stages on top.

## What's here

| Path | What it does |
| --- | --- |
| `bin/omarchy-screensaver` | Drop-in replacement for `/usr/bin/omarchy-screensaver`. Runs [`ttfx`](https://github.com/omacom-io/ttfx)'s `matrix` effect continuously (never resolves into a logo) in `#00FF41` &rarr; `#008F11` &rarr; `#003B00`, tuned for a slower, denser fall than ttfx's defaults. |
| `bin/omarchy-idle-extender` | Small daemon that adds the blank + AC/battery-aware sleep stages on top of Omarchy's native screensaver+lock cycle. |
| `systemd/omarchy-idle-extender.service` | systemd `--user` unit that keeps the daemon running. |
| `hypr/local-bin-priority.lua` | Hyprland snippet that puts `~/.local/bin` ahead of Omarchy's own bin dir on `PATH`, so `bin/omarchy-screensaver` above actually gets picked up instead of the stock one. |
| `shell/idle.json` | The `idle` block to merge into `~/.config/omarchy/shell.json`. |
| `install.sh` | Installs all of the above. |

Nothing here ever touches `/usr/share/omarchy` (Omarchy's own, package-owned,
update-managed files) -- it all lives in `~/.local/bin`,
`~/.config/systemd/user`, and a couple of lines in your own
`~/.config/hypr/hyprland.lua` / `~/.config/omarchy/shell.json`.

## Install

```sh
git clone https://github.com/hbabb/omarchy-matrix-screensaver.git
cd omarchy-matrix-screensaver
./install.sh
```

`install.sh` copies the scripts and systemd unit into place, enables the
service, drops in the Hyprland PATH snippet, and wires it into
`hyprland.lua`. It deliberately does **not** touch `shell.json` for you --
that file also holds your bar layout and plugins, so merge the `idle` block
from `shell/idle.json` into it by hand and save (it hot-reloads).

Preview the screensaver any time with:

```sh
omarchy-launch-screensaver force
```

## Why it works: the PATH trick

Omarchy's idle service (Quickshell) always calls the *name*
`omarchy-launch-screensaver`, which in turn always execs the *name*
`omarchy-screensaver` inside a spawned terminal -- both hardcoded, and both
resolved via `PATH`. Omarchy prepends its own `/usr/share/omarchy/bin`
(a symlink farm to `/usr/bin/omarchy-*`) to the very front of `PATH` at
Hyprland startup, so a same-named script anywhere else -- `~/.local/bin`
included -- normally never gets a chance to run.

`hypr/local-bin-priority.lua` re-prepends `~/.local/bin` *after* Omarchy's
own PATH setup runs, so it wins instead. That one Hyprland-native env
override is all it takes to fork the screensaver without patching or
symlinking over anything Omarchy itself owns.

## Tuning

- **Color**: `--highlight-color`, `--rain-color-gradient`, and
  `--final-gradient-stops` in `bin/omarchy-screensaver`.
- **Fall speed**: `--rain-fall-delay-range` (frame-delay per row step; higher
  = slower).
- **Density** (how quickly gaps between columns fill in):
  `--rain-column-delay-range` (frame delay between new columns; `1-1` is the
  floor -- a new column every frame).
- **Idle timings**: the three constants at the top of
  `bin/omarchy-idle-extender`, plus `idle.screensaver` / `idle.lock` in
  `shell/idle.json` (keep `SCREENSAVER_SECONDS` in the daemon in sync with
  `idle.screensaver`).

Run `ttfx matrix --help` for the full set of effect options.

## Attribution

Forked from [basecamp/omarchy](https://github.com/basecamp/omarchy) (MIT
licensed) and built on [`ttfx`](https://github.com/omacom-io/ttfx) (MIT
licensed, a Rust port of
[ChrisBuilds/terminaltexteffects](https://github.com/ChrisBuilds/terminaltexteffects)),
which ships with Omarchy. See `LICENSE`.
