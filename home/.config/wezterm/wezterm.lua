local wezterm = require("wezterm")

local config = wezterm.config_builder()

config.default_prog = { "/bin/zsh" }

config.font = wezterm.font_with_fallback({ "JetBrains Mono", "LXGW WenKai" })
config.font_size = 12.0

config.window_background_opacity = 0.9
config.window_padding = { left = 8, right = 8, top = 8, bottom = 8 }

config.cursor_blink_rate = 800
config.default_cursor_style = "BlinkingBar"
config.cursor_thickness = 1

config.window_decorations = "NONE"

config.hide_tab_bar_if_only_one_tab = true
config.use_fancy_tab_bar = true
config.show_tab_index_in_tab_bar = false
config.show_close_tab_button_in_tabs = false
config.show_new_tab_button_in_tab_bar = false
config.tab_max_width = 40

config.inactive_pane_hsb = { saturation = 0.5, brightness = 0.85 }

config.window_frame = {
    inactive_titlebar_bg = "#202020",
    active_titlebar_bg = "#202020",
    inactive_titlebar_fg = "#a0a0a0",
    active_titlebar_fg = "#dedede",
    inactive_titlebar_border_bottom = "#444444",
    active_titlebar_border_bottom = "#505050",
    button_fg = "#a0a0a0",
    button_bg = "#202020",
    button_hover_fg = "#f2f2f2",
    button_hover_bg = "#363636",
}

config.colors = {
    foreground = "#e8e8e8",
    background = "#202020",

    cursor_bg = "#f2f2f2",
    cursor_fg = "#202020",
    cursor_border = "#f2f2f2",

    selection_bg = "#d6d6d6",
    selection_fg = "#202020",

    split = "#444444",
    visual_bell = "#363636",
    compose_cursor = "#d6d6d6",

    tab_bar = {
        background = "#202020",
        active_tab = {
            bg_color = "#2a2a2a",
            fg_color = "#f2f2f2",
            intensity = "Bold",
        },
        inactive_tab = {
            bg_color = "#202020",
            fg_color = "#a0a0a0",
        },
        inactive_tab_hover = {
            bg_color = "#363636",
            fg_color = "#dedede",
        },
        new_tab = {
            bg_color = "#202020",
            fg_color = "#a0a0a0",
        },
        new_tab_hover = {
            bg_color = "#363636",
            fg_color = "#f2f2f2",
        },
    },

    ansi = {
        "#363636",
        "#d18b8b",
        "#9ebaa5",
        "#c2b486",
        "#9bb7cf",
        "#b59ab6",
        "#91b8b6",
        "#e6e6e6",
    },

    brights = {
        "#666666",
        "#e2a0a0",
        "#b2cbb7",
        "#d4c492",
        "#b2cbe0",
        "#c9aec9",
        "#abd0ce",
        "#fafafa",
    },

    indexed = {
        [16] = "#c89478",
        [17] = "#d8b1b1",
    },
}

local function basename(path)
    if not path or path == "" then
        return ""
    end
    return string.gsub(path, "^.*[/\\]", "")
end

local function last_dir(path)
    if not path or path == "" then
        return "~"
    end
    local clean = string.gsub(path, "^file://", "")
    local seg = string.gsub(clean, "^(.*[/\\])([^/\\]+)/?$", "%2")
    if seg == clean then
        return clean
    end
    return seg
end

wezterm.on("format-tab-title", function(tab, tabs, panes, config, hover, max_width)
    local pane = tab.active_pane
    local proc = basename(pane.foreground_process_name)
    local cwd = last_dir(pane.current_working_dir)
    local index = tab.tab_index + 1

    local text = string.format(" %d  %s · %s ", index, proc, cwd)
    text = wezterm.truncate_right(text, max_width)

    if tab.is_active then
        return {
            { Foreground = { Color = "#a8bfd2" } },
            { Text = "▍" },
            { Foreground = { Color = "#f2f2f2" } },
            { Text = text },
        }
    end
    if hover then
        return {
            { Foreground = { Color = "#a8bfd2" } },
            { Text = "▍" },
            { Foreground = { Color = "#d6d6d6" } },
            { Text = text },
        }
    end
    return {
        { Foreground = { Color = "#8c8c8c" } },
        { Text = " " .. index .. " " },
        { Text = text },
    }
end)

wezterm.on("format-window-title", function(tab, pane, tabs, panes, config)
    local proc = basename(pane.foreground_process_name)
    local cwd = last_dir(pane.current_working_dir)
    return string.format("%s · %s", proc, cwd)
end)

return config
