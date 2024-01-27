require 'config.settings'
require 'config.mappings'

--    `:help lazy.nvim.txt` for more info
local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system {
    'git',
    'clone',
    '--filter=blob:none',
    'https://github.com/folke/lazy.nvim.git',
    '--branch=stable', -- latest stable release
    lazypath,
  }
end
vim.opt.rtp:prepend(lazypath)

require('lazy').setup({
  -- useless animations
  'eandrju/cellular-automaton.nvim',

  -- Although I like it, I am not ready for this
  -- 'vimpostor/vim-tpipeline',
  {
    'NvChad/nvim-colorizer.lua',
    config = function()
      require('colorizer').setup {}
    end,
  },

  -- Git related plugins
  'tpope/vim-fugitive',

  {
    'catppuccin/nvim',
    name = 'catppuccin',
    config = function()
      require('catppuccin').setup {
        -- transparent_background = true, -- disables setting the background color.
        integrations = {
          harpoon = true,
          fidget = true,
          mason = true,
          neotree = true,
          lsp_trouble = true,
          which_key = true,
        },
      }
      vim.cmd.colorscheme 'catppuccin'
    end,
    priority = 1000,
  },

  -- "gc" to comment visual regions/lines
  { 'numToStr/Comment.nvim', opts = {} },

  { import = 'plugins' },
}, {
  change_detection = {
    enabled = false,
  },
})

-- See `:help vim.highlight.on_yank()`
local highlight_group = vim.api.nvim_create_augroup('YankHighlight', { clear = true })
vim.api.nvim_create_autocmd('TextYankPost', {
  callback = function()
    vim.highlight.on_yank()
  end,
  group = highlight_group,
  pattern = '*',
})
