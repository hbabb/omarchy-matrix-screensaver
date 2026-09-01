#!/bin/bash
# Installs the Matrix-only screensaver and the idle/blank/sleep extender for
# Omarchy (https://omarchy.org). See README.md for what each piece does and
# for the two manual config-merge steps this script can't safely automate.
set -euo pipefail

repo_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "Installing bin/omarchy-screensaver and bin/omarchy-idle-extender to ~/.local/bin ..."
mkdir -p ~/.local/bin
install -m 755 "$repo_dir/bin/omarchy-screensaver" ~/.local/bin/omarchy-screensaver
install -m 755 "$repo_dir/bin/omarchy-idle-extender" ~/.local/bin/omarchy-idle-extender

echo "Installing systemd/omarchy-idle-extender.service to ~/.config/systemd/user ..."
mkdir -p ~/.config/systemd/user
install -m 644 "$repo_dir/systemd/omarchy-idle-extender.service" \
  ~/.config/systemd/user/omarchy-idle-extender.service
systemctl --user daemon-reload
systemctl --user enable --now omarchy-idle-extender.service

echo "Installing hypr/local-bin-priority.lua to ~/.config/hypr ..."
mkdir -p ~/.config/hypr
install -m 644 "$repo_dir/hypr/local-bin-priority.lua" \
  ~/.config/hypr/local-bin-priority.lua

hyprland_lua=~/.config/hypr/hyprland.lua
require_line='require("hypr.local-bin-priority")'
if [[ -f $hyprland_lua ]] && ! grep -qF "$require_line" "$hyprland_lua"; then
  printf '\n-- Matrix screensaver: give ~/.local/bin priority on PATH.\n%s\n' \
    "$require_line" >>"$hyprland_lua"
  echo "Added '$require_line' to $hyprland_lua"
  if command -v hyprctl >/dev/null 2>&1; then
    hyprctl reload >/dev/null 2>&1 && echo "Reloaded Hyprland config."
  fi
else
  echo "NOTE: could not find/update $hyprland_lua automatically."
  echo "      Add this line near the bottom of it yourself:"
  echo "        $require_line"
fi

echo
echo "One manual step left: merge shell/idle.json's \"idle\" block into"
echo "~/.config/omarchy/shell.json (don't overwrite the rest of that file --"
echo "it holds your bar layout and plugins too). It hot-reloads on save."
echo
echo "Done. Restart your terminal/shell to pick up ~/.local/bin (already"
echo "applied to the running Hyprland session and shell)."
