vim.pack.add({
    "https://github.com/nvim-lua/plenary.nvim",
    "https://github.com/MunifTanjim/nui.nvim",
    "https://github.com/nvim-tree/nvim-web-devicons",
    "https://github.com/nvim-lualine/lualine.nvim",
    "https://github.com/nvim-mini/mini.nvim",
    "https://github.com/neovim/nvim-lspconfig",
    "https://github.com/mason-org/mason.nvim",
    -- "https://github.com/lewis6991/gitsigns.nvim",
    { src = "https://github.com/nvim-treesitter/nvim-treesitter", branch = "main" },
    { src = "https://github.com/nvim-telescope/telescope.nvim", version = "*" },
    { src = "https://github.com/nvim-telescope/telescope-fzf-native.nvim", build = 'make' },
    { src = "https://github.com/akinsho/toggleterm.nvim", branch = "main" }
})

vim.cmd.colorscheme("quiet")


-- 加载各插件配置
require("lualine").setup({
    options = {
        theme = {
            normal = {
                a = { fg = "#161616", bg = "#d6d6d6", gui = "bold" },
                b = { fg = "#d6d6d6", bg = "#383838" },
                c = { fg = "#a0a0a0", bg = "#202020" },
            },
            insert = { a = { fg = "#161616", bg = "#94a899", gui = "bold" } },
            visual = { a = { fg = "#161616", bg = "#a797a8", gui = "bold" } },
            replace = { a = { fg = "#161616", bg = "#bd8585", gui = "bold" } },
            command = { a = { fg = "#161616", bg = "#b3a783", gui = "bold" } },
            inactive = {
                a = { fg = "#8c8c8c", bg = "#202020" },
                b = { fg = "#8c8c8c", bg = "#202020" },
                c = { fg = "#8c8c8c", bg = "#202020" },
            },
        },
    },
})
require("nvim-web-devicons").setup({ color_icons = false, default = true })
-- require("gitsigns").setup()
require("plugins.telescope")
require("plugins.mini")
require("plugins.treesitter")
require("plugins.toggleterm")
