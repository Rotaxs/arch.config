require("mason").setup()

local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = vim.tbl_deep_extend("force", capabilities, require("mini.completion").get_lsp_capabilities())

local on_attach = function(client, bufnr)
    local opts = { noremap = true, silent = true, buffer = bufnr }
    vim.notify("LSP attched: " .. client.name, vim.log.levels.INFO)
end

vim.diagnostic.config({
    virtual_text = true
})

-- =============== universal ================

vim.lsp.config("*", {
    capabilities = capabilities,
    on_attach = on_attach
})

-- ================== Lua ===================

vim.lsp.config("lua_ls", {
    settings = {
        Lua = {
            diagnostics = { globals = { "vim" } }
        }
    }
})

-- ================= C/CPP ==================

vim.lsp.config("clangd", {
    cmd = {
        "clangd",
        "--background-index",
        "--suggest-missing-includes",
        "--clang-tidy",
    },
    filetypes = { "c", "cpp", "objc", "objcpp", "cc" },
    root_markers = { ".clangd", "compile_commands.json", "CMakeLists.txt", ".git" },
})

-- ================= Python =================



-- ============ enable server ===============

vim.lsp.enable({
    "lua_ls",
    "clangd"
})
