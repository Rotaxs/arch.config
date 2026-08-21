return {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    keys = {
        { '<leader>e', '<cmd>Neotree toggle<cr>', desc = 'Toggle Neo-tree' },
    },
    dependencies = {
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
      "nvim-tree/nvim-web-devicons",
    },
    opts = {
        close_if_last_window = true,
        popup_border_style = "rounded",
        window = {
          position = "left",
          width = 32,
          mappings = {
                ['<space>'] = 'none',
                ["h"] = function() vim.cmd("vertical resize -5") end,
                ["l"] = function() vim.cmd("vertical resize +5") end,
                ['S'] = 'open_split',
                ['s'] = 'open_vsplit',
                ['t'] = 'open_tabnew',
                ['o'] = 'open',
                ["O"] = {
                    "show_help",
                    nowait = false,
                    config = { title = "Order by", prefix_key = "O" },
                },
                ["Oc"] = { "order_by_created", nowait = false },
                ["Od"] = { "order_by_diagnostics", nowait = false },
                ["Om"] = { "order_by_modified", nowait = false },
                ["On"] = { "order_by_name", nowait = false },
                ["Os"] = { "order_by_size", nowait = false },
                ["Ot"] = { "order_by_type", nowait = false },
            },
        },
        filesystem = {
            follow_current_file = {
                enabled = true,
            },
            use_libuv_file_watcher = true,
            filtered_items = {
                visible = false,
                hide_dotfiles = false,
                hide_gitignored = false,
            },
        },

        default_component_configs = {
          file_size = { enabled = true, width = 12, required_width = 32 },
        },
    },
}
