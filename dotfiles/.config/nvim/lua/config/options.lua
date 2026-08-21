vim.g.have_nerd_font = true

vim.o.number = true
vim.o.relativenumber = true

-- 当保存文件退出后回到文件，是否还能执行 undo/redo 操作
vim.o.undofile = true

-- 光标滚动边距
vim.o.scrolloff = 15

vim.o.showmode = false
vim.o.mouse = 'a'
vim.o.cursorline = true
vim.o.breakindent = true
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true

vim.o.confirm = true
vim.o.splitright = true
vim.o.splitbelow = true
vim.o.list = true
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }
vim.schedule(function() vim.o.clipboard = 'unnamedplus' end)

vim.o.inccommand = 'split'
vim.o.signcolumn = 'yes'

-- ignorecase 表示忽略大小写
-- smartcase 表示当输入中有大写时区分大小写
vim.o.ignorecase = true
vim.o.smartcase = true

vim.o.updatetime = 250
vim.o.timeoutlen = 300



