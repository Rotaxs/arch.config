vim.g.have_nerd_font = true

-- ui 相关
vim.o.number = true
vim.o.relativenumber = true
vim.o.inccommand = 'split'
vim.o.signcolumn = 'yes'
vim.o.cmdheight = 0
vim.o.splitbelow = true
vim.o.splitright = true
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }
vim.o.list = true
vim.o.showmode = false
vim.o.cursorline = true
vim.o.breakindent = true

-- 光标滚动边距
vim.o.scrolloff = 15
vim.o.mouse = 'a'

-- tab 键
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true

-- 未保存文件退出时询问
vim.o.confirm = true

-- 剪切板
vim.schedule(function() vim.o.clipboard = 'unnamedplus' end)

-- ignorecase 表示忽略大小写
-- smartcase 表示当输入中有大写时区分大小写
vim.o.ignorecase = true
vim.o.smartcase = true

vim.o.updatetime = 250
vim.o.timeoutlen = 300
vim.opt.completeopt = "menuone,noselect,fuzzy,nosort"
vim.opt.shortmess:append("c")

-- 撤销文件保存
vim.opt.undodir = vim.fn.stdpath("data") .. "/undodir"
vim.undodir = true
vim.o.undofile = true

-- 文件
vim.opt.swapfile = false
vim.opt.backup = false

