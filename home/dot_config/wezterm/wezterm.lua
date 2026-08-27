local wezterm = require("wezterm")

local config = wezterm.config_builder()

config.color_schemes = {
  ["Hipster Green"] = {
    foreground = "#84c137",
    background = "#0f0a05",
    cursor_bg = "#23ff18",
    cursor_fg = "#0f0a05",
    cursor_border = "#23ff18",
    selection_fg = "#0f0a05",
    selection_bg = "#083905",
    ansi = {
      "#000000",
      "#b6204a",
      "#00a600",
      "#bebe00",
      "#246db2",
      "#b200b2",
      "#00a6b2",
      "#bfbfbf",
    },
    brights = {
      "#666666",
      "#e50000",
      "#86a83e",
      "#e5e500",
      "#0000ff",
      "#e500e5",
      "#00e5e5",
      "#e5e5e5",
    },
    tab_bar = {
      background = "#0c0804",
      active_tab = {
        bg_color = "#083905",
        fg_color = "#eeeeee",
      },
      inactive_tab = {
        bg_color = "#0c0804",
        fg_color = "#84c137",
      },
    },
  },
}

config.color_scheme = "Hipster Green"
config.font = wezterm.font("FixedsysExcelsior Nerd Font Mono")
config.font_size = 10.0
config.line_height = 1.0

config.window_background_opacity = 0.92
config.window_padding = {
  left = 5,
  right = 5,
  top = 5,
  bottom = 5,
}
config.window_decorations = "RESIZE"
config.window_close_confirmation = "NeverPrompt"

config.default_cursor_style = "SteadyBlock"
config.inactive_pane_hsb = {
  brightness = 0.85,
}

config.hide_tab_bar_if_only_one_tab = true
config.tab_bar_at_bottom = true
config.use_fancy_tab_bar = false

config.audible_bell = "Disabled"
config.use_ime = false
config.enable_wayland = true
config.check_for_updates = false
config.automatically_reload_config = true
config.quit_when_all_windows_are_closed = false

config.max_fps = 120
config.animation_fps = 120
config.front_end = "WebGpu"

local home = wezterm.home_dir
config.set_environment_variables = {
  TERMINFO_DIRS = home .. "/.terminfo",
}
config.term = "wezterm"

return config
