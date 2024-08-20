return {
  'johmsalas/text-case.nvim',
  config = function()
    require('textcase').setup {
      substitude_command_name = 'S',

      enabled_methods = {
        'to_snake_case',
        'to_dash_case',
        'to_constant_case',
        'to_camel_case',
        'to_pascal_case',
      },
    }
  end,
  keys = {
    'ga',
    { 'gar', '<cmd>TextCaseStartReplacingCommand<CR>', mode = { 'n', 'x' }, desc = 'Start Replacing Case' },
  },
  cmd = {
    'S',
    'TextCaseStartReplacingCommand',
  },
  lazy = false,
}
