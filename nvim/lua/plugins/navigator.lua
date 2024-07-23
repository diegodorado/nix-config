return {
  'mrjones2014/smart-splits.nvim',
  config = function()
    local smart_splits = require 'smart-splits'

    -- Move cursor between splits
    vim.keymap.set('n', '<C-h>', smart_splits.move_cursor_left, { desc = 'Go to the left pane' })
    vim.keymap.set('n', '<C-j>', smart_splits.move_cursor_down, { desc = 'Go to the bottom pane' })
    vim.keymap.set('n', '<C-k>', smart_splits.move_cursor_up, { desc = 'Go to the top pane' })
    vim.keymap.set('n', '<C-l>', smart_splits.move_cursor_right, { desc = 'Go to the right pane' })

    -- Resize splits
    vim.keymap.set('n', '<C-S-h>', smart_splits.resize_left, { desc = 'Resize split left' })
    vim.keymap.set('n', '<C-S-j>', smart_splits.resize_down, { desc = 'Resize split down' })
    vim.keymap.set('n', '<C-S-k>', smart_splits.resize_up, { desc = 'Resize split up' })
    vim.keymap.set('n', '<C-S-l>', smart_splits.resize_right, { desc = 'Resize split right' })
  end,
}
