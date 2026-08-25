local map = vim.keymap.set

require("mini.pairs").setup()
require("mini.notify").setup()
require("mini.surround").setup()
require("mini.comment").setup()
require("mini.git").setup()
require("mini.diff").setup()

-- ======================= MiniFiles ============================

local minifiles = require("mini.files")
minifiles.setup()
map("n", "-", "<cmd>lua MiniFiles.open()<cr>", { desc = "Toggle mini file explorer" })
map("n", "<leader>-", function()
    minifiles.open(vim.api.nvim_buf_get_name(0), false)
    minifiles.reveal_cwd()
end, { desc = "Toggle into currently opened file" })
local git_ns = vim.api.nvim_create_namespace("mini_files_git")

-- 显示 git status
local set_git_status = function(buf_id)
    vim.api.nvim_buf_clear_namespace(buf_id, git_ns, 0, -1)

    local buf_name = vim.api.nvim_buf_get_name(buf_id)
    local dir = buf_name:match("^minifiles://%d+/(.*)$")
    if dir == nil then return end

    local root_result = vim.system(
        { "git", "-C", dir, "rev-parse", "--show-toplevel" },
        { text = true }
    ):wait()
    if root_result.code ~= 0 then return end

    local git_root = vim.fs.normalize(vim.trim(root_result.stdout))
    local status_result = vim.system(
        { "git", "-C", git_root, "status", "--porcelain=v1", "-z", "--untracked-files=all" }
    ):wait()
    if status_result.code ~= 0 then return end

    local status_map = {}
    local priorities = { added = 1, changed = 2, deleted = 3 }
    local function add_status(path, status)
        local current = status_map[path]
        if current == nil or priorities[status] > priorities[current] then
            status_map[path] = status
        end
    end

    local output = status_result.stdout or ""
    local pos = 1
    while pos <= #output do
        local nul = output:find("\0", pos, true)
        if nul == nil then break end

        local record = output:sub(pos, nul - 1)
        local code, file = record:sub(1, 2), record:sub(4)
        local status = code:find("D", 1, true) and "deleted"
            or ((code:find("A", 1, true) or code == "??") and "added")
            or "changed"
        local path = vim.fs.normalize(git_root .. "/" .. file)

        add_status(path, status)
        local parent = vim.fs.dirname(path)
        while parent ~= git_root and vim.startswith(parent, git_root .. "/") do
            add_status(parent, status)
            parent = vim.fs.dirname(parent)
        end

        pos = nul + 1
        if code:find("R", 1, true) or code:find("C", 1, true) then
            local old_name_end = output:find("\0", pos, true)
            if old_name_end == nil then break end
            pos = old_name_end + 1
        end
    end

    local decorations = {
        added = { "+ ", "DiffAdd" },
        changed = { "~ ", "DiffChange" },
        deleted = { "- ", "DiffDelete" },
    }
    for line = 1, vim.api.nvim_buf_line_count(buf_id) do
        local entry = minifiles.get_fs_entry(buf_id, line)
        local decoration = entry and decorations[status_map[vim.fs.normalize(entry.path)]]
        if decoration then
            vim.api.nvim_buf_set_extmark(buf_id, git_ns, line - 1, 0, {
                virt_text = { decoration },
                virt_text_pos = "inline",
            })
        end
    end
end

vim.api.nvim_create_autocmd("User", {
    pattern = "MiniFilesBufferUpdate",
    callback = function(args)
        set_git_status(args.data.buf_id)
    end,
})

-- ==================== MiniCompletion ==========================

require("mini.completion").setup({
    lsp_completion = {
        auto_setup = true
    },
    window = {
        info = { height = 25, width = 80, border = "single" },
        signature = { height = 25, width = 80, border = "single" }
    }
})
vim.opt.pumheight = 10
local imap_expr = function(lhs, rhs)
    map('i', lhs, rhs, { expr = true })
end
imap_expr('<Tab>',   [[pumvisible() ? "\<C-n>" : "\<Tab>"]])
imap_expr('<S-Tab>', [[pumvisible() ? "\<C-p>" : "\<S-Tab>"]])
_G.cr_action = function()
    if vim.fn.complete_info()['selected'] ~= -1 then
        return '\25'
    end
    return require('mini.pairs').cr()
end

map('i', '<CR>', 'v:lua.cr_action()', { expr = true })

-- ====================== MiniCmdline ===========================

require("mini.cmdline").setup({
    autocorrect = { enable = false }
})

-- ======================= MiniExtra ============================

local miniextra = require("mini.extra")
miniextra.setup()
map("n", "<leader>?", function() miniextra.pickers.keymaps() end, { desc = "Search keymaps" })
map("n", "<leader>xx", function() miniextra.pickers.diagnostic() end, { desc = "Mini Picker Diagnostics"})

-- ================== MiniIndentscope ===========================

require("mini.indentscope").setup({
    mappings = {
        object_scope = 'ii',
        object_scope_with_border = 'ai',
        goto_top = '[i',
        goto_bottom = ']i',
    },
    options = {
        try_as_border = true
    },
    symbol = '│',
})


