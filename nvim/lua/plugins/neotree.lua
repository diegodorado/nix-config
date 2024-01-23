return {
  "nvim-neo-tree/neo-tree.nvim",
  version = "*",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-tree/nvim-web-devicons", -- not strictly required, but recommended
    "MunifTanjim/nui.nvim",
  },
  config = function()
    require('neo-tree').setup {
      popup_border_style = "rounded",
      window = {
        width = 40,
        auto_expand_width = true,
      },
      follow_current_file = {
        enabled = true,          -- This will find and focus the file in the active buffer every time
        --               -- the current file is changed while the tree is open.
        leave_dirs_open = false, -- `false` closes auto expanded dirs, such as with `:Neotree reveal`
      },
      use_libuv_file_watcher = true,
    }
  end,
  vim.keymap.set('n', '<leader>fe', '<Cmd>Neotree toggle<CR>')
}
