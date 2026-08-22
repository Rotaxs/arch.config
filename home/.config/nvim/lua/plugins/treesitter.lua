return {
  'nvim-treesitter/nvim-treesitter',
  lazy = false,
  build = ':TSUpdate',

  config = function()
    local ts = require('nvim-treesitter')

    local common_languages = {
      'lua', 'vim', 'vimdoc', 'query', 'json', 'yaml', 'toml', 'markdown', 'markdown_inline',
      'c', 'cpp', 'rust', 'go', 'python', 'java',
      'html', 'css', 'javascript', 'typescript', 'tsx', 'bash'
    }
    ts.install(common_languages)

    vim.opt.foldlevel = 99
    vim.opt.foldlevelstart = 99
    vim.opt.foldenable = true

    vim.api.nvim_create_autocmd('FileType', {
      pattern = common_languages,
      callback = function()
        pcall(vim.treesitter.start)
        vim.wo.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
        vim.wo.foldmethod = 'expr'
        vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
      end,
    })
  end,
}
