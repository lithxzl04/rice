--------------------------------------------------------------------------------
-- Hyprland config (Lua) — ForeverAlkash/rice (Prism fork), adapted for lith/NixOS
-- Look & feel from the rice; input, monitor, cursor and ALT keybinds from the old config.
-- Prism's shell binds and autostart are loaded at the end (prism.lua / prism-binds.lua).
-- Cheatsheet of every bind: ALT + /
--------------------------------------------------------------------------------

if not hl then
    io.stderr:write("ERROR: hl global not found - wrong config loaded\n")
    os.exit(1)
end

local home = os.getenv("HOME")

------------------
---- PROGRAMS ----
------------------

local mainMod  = "ALT"
local terminal = "kitty"
local files    = "nautilus"

--------------------
---- COLOURS -------
--------------------

-- The rice's static monochrome palette (the author turned off matugen for borders).
local c = {
    primary = "rgba(ffb3afff)", tertiary = "rgba(e7bdbaff)", outline = "rgba(a08c8bff)",
    surface = "rgba(1a1111ff)", shadow = "rgba(000000ff)",
}

------------------
---- MONITORS ----
------------------

hl.monitor({
    output   = "",
    mode     = "preferred",
    position = "auto",
    scale    = "auto",
})

---------------------
---- ENVIRONMENT ----
---------------------

hl.env("XCURSOR_SIZE",         "24")
hl.env("XCURSOR_THEME",        "Bibata-Original-Classic")
hl.env("HYPRCURSOR_SIZE",      "24")
hl.env("QT_QPA_PLATFORM",      "wayland;xcb")
hl.env("QT_QPA_PLATFORMTHEME", "qt6ct")

-------------------
---- AUTOSTART ----
-------------------

-- Wallpaper, Quickshell, clipboard watchers, bt-agent: see prism.lua (loaded below).
-- Polkit agent: Quickshell's own (config.json polkit.enabled).
hl.on("hyprland.start", function()
    hl.exec_cmd("systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP")
    hl.exec_cmd("systemctl --user start xdg-desktop-portal-hyprland.service xdg-desktop-portal.service")
end)

---------------
---- INPUT ----
---------------

hl.config({
    input = {
        kb_layout    = "us",
        follow_mouse = 1,
        sensitivity  = 0,

        touchpad = {
            natural_scroll = false,
        },
    },
})

-- Per-device config (placeholder name; replace with `hyprctl devices` output)
hl.device({
    name        = "epic-mouse-v1",
    sensitivity = -0.5,
})

---------------------
---- LOOK & FEEL ----
---------------------

hl.config({
    general = {
        gaps_in          = 6,
        gaps_out         = 12,
        border_size      = 2,
        resize_on_border = true,
        layout           = "dwindle",

        col = {
            active_border   = { colors = { c.primary, c.tertiary }, angle = 45 },
            inactive_border = { colors = { c.surface, c.outline }, angle = 45 },
        },
    },

    decoration = {
        rounding         = 10,
        active_opacity   = 1.0,
        inactive_opacity = 0.92,

        blur = {
            enabled  = true,
            size     = 6,
            passes   = 3,
            vibrancy = 0.2,
        },

        shadow = {
            enabled      = true,
            range        = 12,
            render_power = 3,
            color        = c.shadow,
        },
    },

    dwindle = {
        preserve_split = true,
    },

    misc = {
        disable_hyprland_logo    = true,
        disable_splash_rendering = true,
        force_default_wallpaper  = 0,
        focus_on_activate        = false,
        key_press_enables_dpms   = true,
        mouse_move_enables_dpms  = true,
    },

    ecosystem = {
        no_update_news  = true,
        no_donation_nag = true,
    },
})

-- Curves and animations (Material 3 easing, a little overshoot on workspaces)
hl.curve("md3_standard", { type = "bezier", points = { {0.2, 0},    {0, 1}   } })
hl.curve("md3_decel",    { type = "bezier", points = { {0.05, 0.7}, {0.1, 1} } })
hl.curve("overshot",     { type = "bezier", points = { {0.05, 0.9}, {0.1, 1.1} } })

hl.animation({ leaf = "windows",          enabled = true, speed = 3,   bezier = "md3_standard", style = "popin 60%" })
hl.animation({ leaf = "border",           enabled = true, speed = 10,  bezier = "default" })
hl.animation({ leaf = "fade",             enabled = true, speed = 2.5, bezier = "md3_decel" })
hl.animation({ leaf = "workspaces",       enabled = true, speed = 3.5, bezier = "overshot",  style = "slide" })
hl.animation({ leaf = "specialWorkspace", enabled = true, speed = 3,   bezier = "md3_decel", style = "slidevert" })

------------------
---- GESTURES ----
------------------

hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })

----------------------
---- WINDOW RULES ----
----------------------

hl.window_rule({
    name  = "float-dialogs",
    match = { class = "^(pavucontrol|org.pulseaudio.pavucontrol|nm-connection-editor|blueman-manager|xdg-desktop-portal-gtk|hyprland-share-picker)$" },
    float = true,
})

hl.window_rule({
    name    = "picture-in-picture",
    match   = { title = "^(Picture-in-Picture|Картинка в картинке)$" },
    float   = true,
    pin     = true,
    opacity = "1.0 override",
})

-- Prism notes window (launcher action "Notes")
hl.window_rule({
    name  = "float-notes",
    match = { class = "^(notes)$" },
    float = true,
})

-- From the old config
hl.window_rule({
    name  = "suppress-maximize-events",
    match = { class = ".*" },
    suppress_event = "maximize",
})

hl.window_rule({
    name  = "fix-xwayland-drags",
    match = {
        class      = "^$",
        title      = "^$",
        xwayland   = true,
        float      = true,
        fullscreen = false,
        pin        = false,
    },
    no_focus = true,
})

------------------
---- KEYBINDS ----
------------------

---- APPS ----
hl.bind(mainMod .. " + Return", hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + E",      hl.dsp.exec_cmd(files))

---- WINDOWS ----
hl.bind(mainMod .. " + SHIFT + Q",     hl.dsp.window.close())
hl.bind(mainMod .. " + SHIFT + F",     hl.dsp.window.fullscreen({ state = 2 }))
hl.bind(mainMod .. " + V",             hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + P",             hl.dsp.window.pseudo())
hl.bind(mainMod .. " + J",             hl.dsp.layout("togglesplit"))
hl.bind(mainMod .. " + G",             hl.dsp.group.toggle())
hl.bind(mainMod .. " + Tab", function()
    hl.dispatch(hl.dsp.window.cycle_next())
    hl.dispatch(hl.dsp.window.bring_to_top())
end)

hl.bind(mainMod .. " + left",  hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + up",    hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + down",  hl.dsp.focus({ direction = "down" }))

hl.bind(mainMod .. " + SHIFT + left",  hl.dsp.window.move({ direction = "l" }))
hl.bind(mainMod .. " + SHIFT + right", hl.dsp.window.move({ direction = "r" }))
hl.bind(mainMod .. " + SHIFT + up",    hl.dsp.window.move({ direction = "u" }))
hl.bind(mainMod .. " + SHIFT + down",  hl.dsp.window.move({ direction = "d" }))

hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

---- WORKSPACES ----
for i = 1, 9 do
    hl.bind(mainMod .. " + " .. i,         hl.dsp.focus({ workspace = i }))
    hl.bind(mainMod .. " + SHIFT + " .. i, hl.dsp.window.move({ workspace = i }))
end
hl.bind(mainMod .. " + 0",         hl.dsp.focus({ workspace = 10 }))
hl.bind(mainMod .. " + SHIFT + 0", hl.dsp.window.move({ workspace = 10 }))

hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up",   hl.dsp.focus({ workspace = "e-1" }))

---- SCRATCHPAD ----
hl.bind(mainMod .. " + S",         hl.dsp.workspace.toggle_special("magic"))
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.window.move({ workspace = "special:magic" }))

-- Prism: shell binds (launcher, dashboard, capture, media keys, …) and autostart.
-- Each Prism bind unbinds its key first, so it wins over anything above.
dofile(home .. "/.config/quickshell/hypr/prism.lua")
dofile(home .. "/.config/quickshell/hypr/prism-binds.lua")

-- Added by hypr-refresh-oc: persistent refresh-rate fragment
pcall(function() dofile(os.getenv("HOME") .. "/.config/hypr/refresh-rate.lua") end)
