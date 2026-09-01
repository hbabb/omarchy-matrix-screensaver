-- Give ~/.local/bin first priority on PATH (ahead of Omarchy's own bin dir),
-- so a same-named script there overrides a stock Omarchy command. Used here
-- so bin/omarchy-screensaver (this repo) overrides the stock, random-effect
-- /usr/bin/omarchy-screensaver -- without ever touching /usr/share/omarchy.
--
-- Install: copy this file to ~/.config/hypr/local-bin-priority.lua, then add
--   require("hypr.local-bin-priority")
-- near the bottom of ~/.config/hypr/hyprland.lua (after
-- `require("default.hypr.omarchy")` so it runs after Omarchy's own PATH
-- setup). `hyprctl reload` picks it up immediately -- no logout needed on
-- this Omarchy build.

do
  local home = os.getenv("HOME")
  local user_bin = home .. "/.local/bin"
  local kept = {}
  for entry in (os.getenv("PATH") or ""):gmatch("[^:]+") do
    if entry ~= user_bin then table.insert(kept, entry) end
  end
  table.insert(kept, 1, user_bin)
  hl.env("PATH", table.concat(kept, ":"))
end
