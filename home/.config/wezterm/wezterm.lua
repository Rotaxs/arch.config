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

config.window_decorations = "RESIZE"

config.hide_tab_bar_if_only_one_tab = true
config.use_fancy_tab_bar = true
config.show_tab_index_in_tab_bar = false
config.show_close_tab_button_in_tabs = false
config.show_new_tab_button_in_tab_bar = false
config.tab_max_width = 40

config.inactive_pane_hsb = { saturation = 0.5, brightness = 0.85 }

config.window_frame = {
    inactive_titlebar_bg = "#161616",
    active_titlebar_bg = "#161616",
    inactive_titlebar_fg = "#8c8c8c",
    active_titlebar_fg = "#d6d6d6",
    inactive_titlebar_border_bottom = "#383838",
    active_titlebar_border_bottom = "#444444",
    button_fg = "#8c8c8c",
    button_bg = "#161616",
    button_hover_fg = "#f2f2f2",
    button_hover_bg = "#2a2a2a",
}

config.colors = {
    foreground = "#e4e4e4",
    background = "#161616",

    cursor_bg = "#f2f2f2",
    cursor_fg = "#161616",
    cursor_border = "#f2f2f2",

    selection_bg = "#d6d6d6",
    selection_fg = "#161616",

    split = "#383838",
    visual_bell = "#2a2a2a",
    compose_cursor = "#d6d6d6",

    tab_bar = {
        background = "#161616",
        active_tab = {
            bg_color = "#202020",
            fg_color = "#f2f2f2",
            intensity = "Bold",
        },
        inactive_tab = {
            bg_color = "#161616",
            fg_color = "#8c8c8c",
        },
        inactive_tab_hover = {
            bg_color = "#2a2a2a",
            fg_color = "#d6d6d6",
        },
        new_tab = {
            bg_color = "#161616",
            fg_color = "#8c8c8c",
        },
        new_tab_hover = {
            bg_color = "#2a2a2a",
            fg_color = "#f2f2f2",
        },
    },

    ansi = {
        "#2a2a2a",
        "#c47f7f",
        "#91ad98",
        "#b6a678",
        "#8faac1",
        "#aa8dab",
        "#84aaa8",
        "#dedede",
    },

    brights = {
        "#555555",
        "#dc9696",
        "#a8c2ad",
        "#ccbc8d",
        "#a8bfd2",
        "#c0a5c1",
        "#9fc3c1",
        "#f6f6f6",
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