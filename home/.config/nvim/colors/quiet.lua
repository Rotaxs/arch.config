vim.cmd.highlight("clear")
if vim.fn.exists("syntax_on") == 1 then
    vim.cmd.syntax("reset")
end
vim.o.background = "dark"
vim.g.colors_name = "quiet"

local colors = {
    bg = "#202020",
    surface = "#202020",
    elevated = "#363636",
    border = "#505050",
    muted = "#a0a0a0",
    text = "#e8e8e8",
    bright = "#fafafa",
    red = "#d18b8b",
    green = "#9ebaa5",
    yellow = "#c2b486",
    blue = "#9bb7cf",
    magenta = "#b59ab6",
    cyan = "#91b8b6",
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
vim.g.terminal_color_1 = "#d18b8b"
vim.g.terminal_color_2 = "#9ebaa5"
vim.g.terminal_color_3 = "#c2b486"
vim.g.terminal_color_4 = "#9bb7cf"
vim.g.terminal_color_5 = "#b59ab6"
vim.g.terminal_color_6 = "#91b8b6"
vim.g.terminal_color_7 = "#e6e6e6"
vim.g.terminal_color_8 = "#666666"
vim.g.terminal_color_9 = "#e2a0a0"
vim.g.terminal_color_10 = "#b2cbb7"
vim.g.terminal_color_11 = "#d4c492"
vim.g.terminal_color_12 = "#b2cbe0"
vim.g.terminal_color_13 = "#c9aec9"
vim.g.terminal_color_14 = "#abd0ce"
vim.g.terminal_color_15 = "#fafafa"
