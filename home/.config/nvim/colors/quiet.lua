vim.cmd.highlight("clear")
if vim.fn.exists("syntax_on") == 1 then
    vim.cmd.syntax("reset")
end
vim.o.background = "dark"
vim.g.colors_name = "quiet"

local colors = {
    bg = "#161616",
    surface = "#202020",
    elevated = "#2a2a2a",
    border = "#444444",
    muted = "#8c8c8c",
    text = "#d6d6d6",
    bright = "#f2f2f2",
    red = "#bd8585",
    green = "#94a899",
    yellow = "#b3a783",
    blue = "#94a3b2",
    magenta = "#a797a8",
    cyan = "#8da7a6",
}

local groups = {
    Normal = { fg = colors.text, bg = colors.bg },
    NormalFloat = { fg = colors.text, bg = colors.surface },
    FloatBorder = { fg = colors.border, bg = colors.surface },
    ColorColumn = { bg = colors.surface },
    CursorLine = { bg = colors.surface },
    CursorLineNr = { fg = colors.bright, bold = true },
    LineNr = { fg = colors.border },
    SignColumn = { fg = colors.muted, bg = colors.bg },
    VertSplit = { fg = colors.border },
    WinSeparator = { fg = colors.border },
    Visual = { fg = colors.bg, bg = colors.text },
    Search = { fg = colors.bg, bg = colors.muted },
    IncSearch = { fg = colors.bg, bg = colors.bright },
    MatchParen = { fg = colors.bright, bold = true, underline = true },
    Pmenu = { fg = colors.text, bg = colors.surface },
    PmenuSel = { fg = colors.bg, bg = colors.text },
    StatusLine = { fg = colors.text, bg = colors.elevated },
    StatusLineNC = { fg = colors.muted, bg = colors.surface },
    TabLine = { fg = colors.muted, bg = colors.surface },
    TabLineSel = { fg = colors.bright, bg = colors.elevated, bold = true },
    Comment = { fg = colors.muted, italic = true },
    Constant = { fg = colors.magenta },
    String = { fg = colors.green },
    Character = { fg = colors.green },
    Number = { fg = colors.magenta },
    Boolean = { fg = colors.magenta, bold = true },
    Identifier = { fg = colors.text },
    Function = { fg = colors.blue },
    Statement = { fg = colors.bright, bold = true },
    Conditional = { fg = colors.bright, bold = true },
    Repeat = { fg = colors.bright, bold = true },
    Operator = { fg = colors.muted },
    PreProc = { fg = colors.yellow },
    Type = { fg = colors.cyan },
    Special = { fg = colors.yellow },
    Underlined = { fg = colors.blue, underline = true },
    Todo = { fg = colors.bg, bg = colors.yellow, bold = true },
    Error = { fg = colors.red, bold = true },
    DiagnosticError = { fg = colors.red },
    DiagnosticWarn = { fg = colors.yellow },
    DiagnosticInfo = { fg = colors.blue },
    DiagnosticHint = { fg = colors.muted },
    DiffAdd = { fg = colors.green, bg = colors.surface },
    DiffChange = { fg = colors.yellow, bg = colors.surface },
    DiffDelete = { fg = colors.red, bg = colors.surface },
}

for group, opts in pairs(groups) do
    vim.api.nvim_set_hl(0, group, opts)
end

vim.g.terminal_color_0 = colors.elevated
vim.g.terminal_color_1 = "#c47f7f"
vim.g.terminal_color_2 = "#91ad98"
vim.g.terminal_color_3 = "#b6a678"
vim.g.terminal_color_4 = "#8faac1"
vim.g.terminal_color_5 = "#aa8dab"
vim.g.terminal_color_6 = "#84aaa8"
vim.g.terminal_color_7 = "#dedede"
vim.g.terminal_color_8 = "#555555"
vim.g.terminal_color_9 = "#dc9696"
vim.g.terminal_color_10 = "#a8c2ad"
vim.g.terminal_color_11 = "#ccbc8d"
vim.g.terminal_color_12 = "#a8bfd2"
vim.g.terminal_color_13 = "#c0a5c1"
vim.g.terminal_color_14 = "#9fc3c1"
vim.g.terminal_color_15 = "#f6f6f6"
