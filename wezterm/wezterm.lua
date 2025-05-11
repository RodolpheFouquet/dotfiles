local wezterm = require("wezterm")
local config = wezterm.config_builder()
local sessionizer = wezterm.plugin.require("https://github.com/mikkasendke/sessionizer.wezterm")
local zoxide = wezterm.plugin.require("https://github.com/mikkasendke/sessionizer-zoxide.git")
local my_schema = {
	sessionizer.DefaultWorkspace({ label_overwrite = "🏠 Home" }),
	wezterm.home_dir .. "/.config/wezterm",
	wezterm.home_dir .. "/.config/nvim",
	wezterm.home_dir .. "/.config/xmonad",
	wezterm.home_dir .. "/.config/xmobar",
	wezterm.home_dir .. "/.config/fish",
	wezterm.home_dir .. "/.config",
	wezterm.home_dir .. "/Code",
	sessionizer.AllActiveWorkspaces({}),
	sessionizer.FdSearch(wezterm.home_dir .. "/Code"),
	zoxide.Zoxide({}),
}

config.keys = {
	{ key = "s", mods = "SUPER", action = sessionizer.show(my_schema) },
}

config.color_scheme = "Eldritch"
config.enable_wayland = true
config.enable_tab_bar = false

return config
