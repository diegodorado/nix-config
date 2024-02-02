return {
  'stevearc/conform.nvim',
  dependencies = { 'WhoIsSethDaniel/mason-tool-installer.nvim' },
  config = function()
    require('mason-tool-installer').setup {
      -- a list of all tools you want to ensure are installed upon
      -- start; they should be the names Mason uses for each tool
      ensure_installed = {
        -- "black",
        'shfmt',
        'prettierd',
        'stylua',
        'eslint_d',
        'google-java-format',
      },
    }

    require('conform').setup {
      formatters_by_ft = {
        java = { 'google-java-format' },
        javascript = { 'prettierd', 'eslint_d' },
        javascriptreact = { 'prettierd', 'eslint_d' },
        typescript = { 'prettierd', 'eslint_d' },
        typescriptreact = { 'prettierd', 'eslint_d' },
        vue = { 'prettierd', 'eslint_d' },
        css = { 'prettierd' },
        scss = { 'prettierd' },
        html = { 'prettierd' },
        json = { 'prettierd' },
        jsonc = { 'prettierd' },
        yaml = { 'prettierd' },
        markdown = { 'prettierd' },
        graphql = { 'prettierd' },
        handlebars = { 'prettierd' },
        lua = { 'stylua' },
        sh = { 'shfmt' },
        swift = { 'swift_format' },
      },
      log_level = vim.log.levels.DEBUG,

      format_on_save = {
        -- These options will be passed to conform.format()
        async = false,
        -- eslint_d is fast, but not the very first run
        timeout_ms = 5000,
        lsp_fallback = true,
      },
    }
  end,
}
