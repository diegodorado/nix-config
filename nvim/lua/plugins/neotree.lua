-- neotree filter was buggy as hell
-- nvim-tree is less feature complete,
-- but at least searching works ok
return {
  'nvim-tree/nvim-tree.lua',
  version = '*',
  lazy = false,
  dependencies = {
    'nvim-tree/nvim-web-devicons',
  },
  config = function()
    require('nvim-tree').setup {
      view = {
        width = 50,
      },
      renderer = {
        group_empty = true,
      },
      -- filters = {
      --   dotfiles = true,
      -- },
    }
  end,
  vim.keymap.set('n', '<leader>fe', '<Cmd>NvimTreeToggle<CR>'),
}
