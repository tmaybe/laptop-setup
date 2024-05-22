-- Pull in the wezterm API
local wezterm = require("wezterm")

-- This will hold the configuration.
local config = wezterm.config_builder()

-- This is where you actually apply your config choices
config.enable_scroll_bar = true
config.font = wezterm.font("Operator Mono", { weight = "Book" })
config.font_size = 18
config.harfbuzz_features = { "calt=0", "clig=0", "liga=0" } -- disable ligatures
config.hide_tab_bar_if_only_one_tab = true
config.scrollback_lines = 100000
config.window_padding = { left = "0cell", right = "0cell", top = "0cell", bottom = "0cell" }

-- and finally, return the configuration to wezterm
return config
