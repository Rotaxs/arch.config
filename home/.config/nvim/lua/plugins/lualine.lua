return {
    'nvim-lualine/lualine.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    opts = {
        theme = 'material',
        sections = {
            lualine_c = {
                { 'filename', path = 1 },
                {
                    function()
                        local clients = vim.lsp.get_clients({ bufnr = 0 })
                        return table.concat(vim.tbl_map(function(c) return c.name end, clients), ' ')
                    end,
                    icon = '',
                },
            },
        },
    },
}
