local ensure_installed = {
    "cpp", "c", "lua",
    "markdown_inline"
}

require("nvim-treesitter").install(ensure_installed)

vim.api.nvim_create_autocmd("FileType", {
    pattern = "*",
    callback = function(args)
        local buf = args.buf
        local ft = vim.bo[buf].filetype
        local lang = vim.treesitter.language.get_lang(ft)
        if not lang then
            return
        end
        pcall(vim.treesitter.start, buf, lang)
    end,
})


