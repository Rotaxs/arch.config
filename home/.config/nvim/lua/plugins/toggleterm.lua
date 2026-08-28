require("toggleterm").setup({
    open_mapping = [[<c-j>]],
    hide_numbers = true,
    direction = "float",
    float_opts = {
        border = "curved"
    }
})

vim.keymap.set({ "n", "t" }, "<leader>t1", "<cmd>1ToggleTerm<CR>", { desc = "Terminal 1" })
vim.keymap.set({ "n", "t" }, "<leader>t2", "<cmd>2ToggleTerm<CR>", { desc = "Terminal 2" })
vim.keymap.set({ "n", "t" }, "<leader>t3", "<cmd>3ToggleTerm<CR>", { desc = "Terminal 3" })
