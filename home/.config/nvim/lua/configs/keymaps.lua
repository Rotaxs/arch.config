vim.g.mapleader = ' '
vim.g.maplocalleader = ','

local map = vim.keymap.set

map("n", "<leader>re", "<cmd>restart<cr>", { desc = "[Re]start Neovim" })

-- 保存和退出文件
map("n", "<leader>w", "<cmd>w<cr>", { desc = "[W]rite file" })
map("n", "<leader>q", "<cmd>q<cr>", { desc = "[Q]uit file" })

-- 多窗口时移动焦点
map("n", "<C-h>", "<C-w>h", { desc = "Move to left window" } )
map("n", "<C-j>", "<C-w>j", { desc = "Move to bottom window" } )
map("n", "<C-k>", "<C-w>k", { desc = "Move to up window" } )
map("n", "<C-l>", "<C-w>l", { desc = "Move to right window" } )

-- 清除搜索后的高亮
map("n", "<Esc>", ":nohl<cr>", { desc = "Clear search highlighting", silent = true })

-- 在可视模式下移动行
map("v", "J", ":m '>+1<cr>gv=gv", { desc = "Move lines down in visual selection" })
map("v", "K", ":m '<-2<cr>gv=gv", { desc = "Move lines up in visual selection" })

-- 在可视模式下更加方便地缩进
map("v", "<", "<gv", { desc = "Unindent and keep selection" })
map("v", ">", ">gv", { desc = "Indent and keep selection" })

-- 搜索时光标始终在中间
map("n", "n", "nzzzv", { desc = "Next search result cursor centered"})
map("n", "N", "Nzzzv", { desc = "Previous Next search result cursor centered"})

-- LSP
map("n", "gd", vim.lsp.buf.definition, { desc = "Go to definition" })
map("n", "<leader>f", vim.lsp.buf.format, { desc = "Format local buffer" })

-- 分栏
map("n", "<C-s>", "<cmd>vsplit<cr>", { desc = "VSplit" })
map("n", "<C-x>", "<cmd>split<cr>", { desc = "Split" })

