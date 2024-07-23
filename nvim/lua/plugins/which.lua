-- Useful plugin to show you pending keybinds.
return {
  'folke/which-key.nvim',
  config = function()
    -- document existing key chains
    require('which-key').add {
      { '<leader>c', group = '[C]ode' },
      { '<leader>d', group = '[D]ocument' },
      { '<leader>g', group = '[G]it' },
      { '<leader>h', group = 'Git [H]unk' },
      { '<leader>r', group = '[R]ename' },
      { '<leader>s', group = '[S]earch' },
      { '<leader>t', group = '[T]oggle' },
      { '<leader>w', group = '[W]orkspace' },
    }
    -- register which-key VISUAL mode
    -- required for visual <leader>hs (hunk stage) to work
    require('which-key').add {
      mode = { 'v' },
      { '<leader>', group = 'VISUAL <leader>' },
      { '<leader>h', 'Git [H]unk' },
    }
  end,
}
