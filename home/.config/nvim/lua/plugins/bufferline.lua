local function safe_close_buffer(bufnr)
    bufnr = (bufnr and bufnr ~= 0) and bufnr or vim.api.nvim_get_current_buf()

    if bufnr == vim.api.nvim_get_current_buf() then
        vim.cmd('bprevious')
    end

    if vim.api.nvim_buf_is_valid(bufnr) then
        vim.cmd('bdelete! ' .. bufnr)
    end
end

return {
    'akinsho/bufferline.nvim',
    version = '*',
    dependencies = 'nvim-tree/nvim-web-devicons',
    keys = {
        { '<S-h>', '<cmd>BufferLineCyclePrev<cr>', desc = 'Prev Buffer' },
        { '<S-l>', '<cmd>BufferLineCycleNext<cr>', desc = 'Next Buffer' },
        { '<leader>bP', '<cmd>BufferLinePickClose<cr>', desc = 'Pick Close Buffer' },
        { '<leader>bd', function() safe_close_buffer(0) end, desc = 'Delete Current Buffer' },
    },
    init = function() vim.opt.termguicolors = true end,
    opts = {
        options = {
            numbers = 'ordinal',
            -- 覆盖默认删除指令：无论是 Pick 还是鼠标点击关闭，都调用原生 safe_close_buffer
            close_command = function(bufnr) safe_close_buffer(bufnr) end,
            right_mouse_command = function(bufnr) safe_close_buffer(bufnr) end,

            offsets = {
                {
                    filetype = "neo-tree",
                    text = "File Explorer",
                    text_align = "left",
                    separator = true,
                },
            },
        },
    },
}
