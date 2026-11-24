-- Prism keybinds — every action from action_commands.md on a key.
-- install.sh loads this at the end of hyprland.lua, after your own binds. Each key
-- here is unbound first, so it replaces whatever that key did before instead of
-- running both. Edit freely; ALT + / shows every bind (this file included).

local mainMod = "ALT"

-- bind a key, replacing any earlier bind on it
local function bind(keys, action, opts)
    pcall(hl.unbind, keys)
    hl.bind(keys, action, opts)
end

-- volume / brightness / media go through Prism (shows the OSD); if the shell
-- isn't running they fall back to the plain tools so the keys always work
local function osd(ipc, fallback)
    return hl.dsp.exec_cmd("qs ipc call " .. ipc .. " || " .. fallback)
end

-- lith: main mod is ALT. Keys from the old ALT setup keep their meaning
-- (D launcher, M power, N notifications, SHIFT+N dnd, R record, V float, S scratch);
-- rice-only actions moved to free ALT / ALT+CTRL combos.

---- PANELS ----
bind(mainMod .. " + D",                hl.dsp.exec_cmd("qs ipc call launcher toggle"))
bind(mainMod .. " + escape",           hl.dsp.exec_cmd("qs ipc call dashboard toggle"))
bind(mainMod .. " + SHIFT + escape",   hl.dsp.exec_cmd("qs ipc call controls toggle"))
bind(mainMod .. " + N",                hl.dsp.exec_cmd("qs ipc call sidebar toggle"))
bind(mainMod .. " + O",                hl.dsp.exec_cmd("qs ipc call overview toggle"))
bind(mainMod .. " + SHIFT + TAB",      hl.dsp.exec_cmd("qs ipc call switcher toggle"))
bind(mainMod .. " + M",                hl.dsp.exec_cmd("qs ipc call power toggle"))
bind(mainMod .. " + slash",            hl.dsp.exec_cmd("qs ipc call cheatsheet toggle"))

---- PICKERS ----
-- ALT+V stays "toggle float" (old binding), so clipboard is ALT+C
bind(mainMod .. " + C",                hl.dsp.exec_cmd("qs ipc call clipboard toggle"))
bind(mainMod .. " + period",           hl.dsp.exec_cmd("qs ipc call emoji toggle"))
bind(mainMod .. " + W",                hl.dsp.exec_cmd("qs ipc call wallpaper toggle"))
bind(mainMod .. " + SHIFT + W",        hl.dsp.exec_cmd("qs ipc call wallpaper random"))

---- CAPTURE ----
bind("Print",                          hl.dsp.exec_cmd("qs ipc call screenshot menu"))
bind("SHIFT + Print",                  hl.dsp.exec_cmd("qs ipc call screenshot region"))
bind("CTRL + Print",                   hl.dsp.exec_cmd("qs ipc call screenshot full"))
bind(mainMod .. " + Print",            hl.dsp.exec_cmd("qs ipc call screenshot window"))
bind(mainMod .. " + R",                hl.dsp.exec_cmd("qs ipc call record toggle"))
bind(mainMod .. " + SHIFT + R",        hl.dsp.exec_cmd("qs ipc call record quick"))

---- TOGGLES ----
bind(mainMod .. " + SHIFT + N",        hl.dsp.exec_cmd("qs ipc call toggle dnd"))
bind(mainMod .. " + CTRL + N",         hl.dsp.exec_cmd("qs ipc call notify clear"))
bind(mainMod .. " + CTRL + T",         hl.dsp.exec_cmd("qs ipc call theme toggle"))
bind(mainMod .. " + CTRL + F",         hl.dsp.exec_cmd("qs ipc call focus toggle"))
bind(mainMod .. " + CTRL + C",         hl.dsp.exec_cmd("qs ipc call toggle caffeine"))
bind(mainMod .. " + CTRL + G",         hl.dsp.exec_cmd("qs ipc call toggle gamemode"))

---- MINIMIZE ----
bind(mainMod .. " + CTRL + Space",     hl.dsp.window.move({ workspace = "special:minimize", follow = false }))
bind(mainMod .. " + SHIFT + Space",    hl.dsp.workspace.toggle_special("minimize"))

---- SESSION ----
bind(mainMod .. " + L",                hl.dsp.exec_cmd("qs ipc call lock lock"))

---- MEDIA KEYS ----
bind("XF86AudioRaiseVolume",  osd("osd volumeUp", "wpctl set-volume -l 1.5 @DEFAULT_AUDIO_SINK@ 5%+"), { locked = true, repeating = true })
bind("XF86AudioLowerVolume",  osd("osd volumeDown", "wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),      { locked = true, repeating = true })
bind("XF86AudioMute",         osd("osd mute", "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),          { locked = true })
bind("XF86AudioMicMute",      osd("osd micMute", "wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),     { locked = true })
bind("XF86MonBrightnessUp",   osd("osd brightnessUp", "brightnessctl set 5%+"),                       { locked = true, repeating = true })
bind("XF86MonBrightnessDown", osd("osd brightnessDown", "brightnessctl set 5%-"),                     { locked = true, repeating = true })
bind("XF86AudioPlay",         osd("media playPause", "playerctl play-pause"),                         { locked = true })
bind("XF86AudioPause",        osd("media playPause", "playerctl play-pause"),                         { locked = true })
bind("XF86AudioNext",         osd("media next", "playerctl next"),                                    { locked = true })
bind("XF86AudioPrev",         osd("media previous", "playerctl previous"),                            { locked = true })
