return {
  "stevearc/conform.nvim",
  dependencies = { 'WhoIsSethDaniel/mason-tool-installer.nvim' },
  config = function()
    require("mason-tool-installer").setup({
      -- a list of all tools you want to ensure are installed upon
      -- start; they should be the names Mason uses for each tool
      ensure_installed = {
        -- "black",
        "shfmt",
        "prettierd",
        "stylua",
        "eslint_d",
      },
    })

    require("conform").setup({
      formatters_by_ft = {
        javascript = { "prettierd", "eslint_d" },
        javascriptreact = { "prettierd", "eslint_d" },
        typescript = { "prettierd", "eslint_d" },
        typescriptreact = { "prettierd", "eslint_d" },
        vue = { "prettierd", "eslint_d" },
        css = { "prettierd" },
        scss = { "prettierd" },
        html = { "prettierd" },
        json = { "prettierd" },
        jsonc = { "prettierd" },
        yaml = { "prettierd" },
        markdown = { "prettierd" },
        graphql = { "prettierd" },
        handlebars = { "prettierd" },
        lua = { "stylua" },
        sh = { "shfmt" },
      },
      format_on_save = {
        -- These options will be passed to conform.format()
        async = false,
        -- eslint_d is fast, but not the very first run
        timeout_ms = 2500,
        lsp_fallback = true,
      },
    })
  end,
}
