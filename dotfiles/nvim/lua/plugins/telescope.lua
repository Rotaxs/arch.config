return {
    'nvim-telescope/telescope.nvim', version = '*', 
    dependencies = {
        'nvim-lua/plenary.nvim',
        { 'nvim-telescope/telescope-fzy-native.nvim', build = 'make' },
    },
    keys = {
        { '<leader>ff', '<cmd>Telescope find_files<cr>', desc = 'Telescope Find files' },
        { '<leader>fg', '<cmd>Telescope live_grep<cr>', desc = 'Telescope live grep' },
        { '<leader>fb', '<cmd>Telescope buffers<cr>', desc = 'Telescope buffers' },
        { '<leader>ft', '<cmd>Telescope treesitter<cr>', desc = 'Telescope treesitter symbols' },
        { '<leader>fh', '<cmd>Telescope help_tags<cr>', desc = 'Telescope help tags' },
    },
    config = function()
        local telescope = require('telescope')
        telescope.setup({
            defaults = {
            },
            pickers = {
            },
            extensions = {
                fzy_native = {
                    override_generic_sorter = true,
                    override_file_sorter = true,
                },
            },
        })
        pcall(telescope.load_extension, 'fzy_native')
    end,
}
