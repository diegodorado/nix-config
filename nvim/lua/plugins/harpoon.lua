return {
  'theprimeagen/harpoon',
  branch = 'harpoon2',
  dependencies = { 'nvim-lua/plenary.nvim' },
  config = function()
    local harpoon = require 'harpoon'

    harpoon:setup {}

    vim.keymap.set('n', '<leader>i', function()
      harpoon:list():append()
    end, { desc = '[A]dd to Harpoon' })
    vim.keymap.set('n', '<leader>o', function()
      harpoon.ui:toggle_quick_menu(harpoon:list())
    end, { desc = '[O]pen Harpoon' })

    vim.keymap.set('n', '<leader>j', function()
      harpoon:list():select(1)
    end, { desc = 'Harpoon #1 buffer' })
    vim.keymap.set('n', '<leader>k', function()
      harpoon:list():select(2)
    end, { desc = 'Harpoon #2 buffer' })
    vim.keymap.set('n', '<leader>l', function()
      harpoon:list():select(3)
    end, { desc = 'Harpoon #3 buffer' })
    vim.keymap.set('n', '<leader>;', function()
      harpoon:list():select(4)
    end, { desc = 'Harpoon #4 buffer' })
  end,
}
