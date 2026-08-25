vim.pack.add({
    "https://github.com/nvim-lua/plenary.nvim",
    "https://github.com/MunifTanjim/nui.nvim",
    "https://github.com/nvim-tree/nvim-web-devicons",
    "https://github.com/nvim-lualine/lualine.nvim",
    "https://github.com/nvim-mini/mini.nvim",
    "https://github.com/neovim/nvim-lspconfig",
    "https://github.com/mason-org/mason.nvim",
    { src = "https://github.com/nvim-treesitter/nvim-treesitter", branch = "main" },
    { src = "https://github.com/catppuccin/nvim", name = "catppuccin" },
    { src = "https://github.com/nvim-telescope/telescope.nvim", version = "*" },
    { src = "https://github.com/nvim-telescope/telescope-fzf-native.nvim", build = 'make' },
    { src = "https://github.com/akinsho/toggleterm.nvim", branch = "main" }
})

vim.cmd.colorscheme("catppuccin-nvim")


-- 加载各插件配置
require("lualine").setup()
require("plugins.telescope")
require("plugins.mini")
require("plugins.treesitter")
require("plugins.toggleterm")
