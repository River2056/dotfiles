local wezterm = require("wezterm")
print("home_dir: " .. wezterm.home_dir)

local config = {}

config.font = wezterm.font("MesloLGS NF")
config.font_size = 14
config.color_scheme = "Tomorrow Night"
config.enable_tab_bar = false
config.window_decorations = "RESIZE"

config.window_background_opacity = 0.8
config.macos_window_background_blur = 10

config.send_composed_key_when_left_alt_is_pressed = true
config.send_composed_key_when_right_alt_is_pressed = true

local dimmer = { brightness = 0.1 }
local bg_path = wezterm.home_dir .. "/.config/wezterm/community_participation.jpg"
config.background = {
    {
        source = {
            File = bg_path,
        },
        repeat_x = "Mirror",
        hsb = dimmer,
        -- attachment = { Parallax = 0.1 }
    },
}

return config
