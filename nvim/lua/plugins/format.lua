return {
  'stevearc/conform.nvim',
  dependencies = { 'WhoIsSethDaniel/mason-tool-installer.nvim' },
  config = function()
    require('mason-tool-installer').setup {
      -- a list of all tools you want to ensure are installed upon
      -- start; they should be the names Mason uses for each tool
      ensure_installed = {
        -- "black",
        'rustfmt',
        'shfmt',
        'prettierd',
        'stylua',
        'google-java-format',
      },
    }

    require('conform').setup {
      formatters_by_ft = {
        java = { 'google-java-format' },
        javascript = { 'prettierd' },
        javascriptreact = { 'prettierd' },
        typescript = { 'prettierd' },
        typescriptreact = { 'prettierd' },
        vue = { 'prettierd' },
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
        rust = { 'rustfmt' },
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
