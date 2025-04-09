local servers = {
  asm_lsp = {},
  clangd = {},
  rnix = {},
  ols = {}, -- odin language server
  openscad_lsp = {},
  -- gopls = {},
  -- pyright = {},
  rust_analyzer = {},
  biome = {},
  eslint = {},
  ts_ls = {},
  -- html = { filetypes = { 'html', 'twig', 'hbs'} },
  lua_ls = {
    Lua = {
      workspace = { checkThirdParty = false },
      telemetry = { enable = false },
      -- NOTE: toggle below to ignore Lua_LS's noisy `missing-fields` warnings
      -- diagnostics = { disable = { 'missing-fields' } },
    },
  },
  zls = {}, -- zig language server
}

--  This function gets run when an LSP connects to a particular buffer.
local on_attach = function(client, bufnr)
  local nmap = function(keys, func, desc)
    if desc then
      desc = 'LSP: ' .. desc
    end
    vim.keymap.set('n', keys, func, { buffer = bufnr, desc = desc })
  end

  if client.name == 'eslint' then
    vim.api.nvim_create_autocmd('BufWritePost', {
      buffer = bufnr,
      command = 'EslintFixAll',
    })
  end

  nmap('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')
  nmap('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction')

  nmap('gd', require('telescope.builtin').lsp_definitions, '[G]oto [D]efinition')
  nmap('gr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')
  nmap('gI', require('telescope.builtin').lsp_implementations, '[G]oto [I]mplementation')
  nmap('<leader>D', require('telescope.builtin').lsp_type_definitions, 'Type [D]efinition')
  nmap('<leader>ds', require('telescope.builtin').lsp_document_symbols, '[D]ocument [S]ymbols')
  nmap('<leader>ws', require('telescope.builtin').lsp_dynamic_workspace_symbols, '[W]orkspace [S]ymbols')

  -- See `:help K` for why this keymap
  nmap('K', vim.lsp.buf.hover, 'Hover Documentation')
end

return {
  -- LSP Configuration & Plugins
  'neovim/nvim-lspconfig',
  dependencies = {
    -- Automatically install LSPs to stdpath for neovim
    { 'williamboman/mason.nvim', config = true },
    'williamboman/mason-lspconfig.nvim',

    -- Useful status updates for LSP
    -- NOTE: `opts = {}` is the same as calling `require('fidget').setup({})`
    { 'j-hui/fidget.nvim', opts = {} },

    {
      'VonHeikemen/lsp-zero.nvim',
      branch = 'v2.x',
      config = false,
      init = function()
        -- Disable automatic setup, we are doing it manually
        vim.g.lsp_zero_extend_cmp = 0
        vim.g.lsp_zero_extend_lspconfig = 0
      end,
    },

    -- Additional lua configuration, makes nvim stuff amazing!
    'folke/neodev.nvim',
  },
  config = function()
    -- mason-lspconfig requires that these setup functions are called in this order
    -- before setting up the servers.
    require('mason').setup()
    -- Ensure the servers above are installed
    require('mason-lspconfig').setup {
      ensure_installed = vim.tbl_keys(servers),
    }

    -- Setup neovim lua configuration
    require('neodev').setup()

    -- nvim-cmp supports additional completion capabilities, so broadcast that to servers
    local capabilities = vim.lsp.protocol.make_client_capabilities()
    capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities)

    local lsp = require 'lsp-zero'
    local lspconfig = require 'lspconfig'
    lsp.extend_lspconfig()
    local jails_bin = vim.fn.stdpath 'config' .. '/jails/bin/jails'
    local configs = require 'lspconfig.configs'
    configs.jails = {
      default_config = {
        cmd = { jails_bin },
        root_dir = lspconfig.util.root_pattern('jails.json', 'build.jai', 'main.jai'),
        filetypes = { 'jai' },
        name = 'Jails',
        on_attach = on_attach,
        capabilities = capabilities,
      },
    }
    lspconfig.jails.setup {}

    -- dart special case: lsp is not installed by mason. it is dart itself
    require('lspconfig').dartls.setup {
      capabilities = capabilities,
      on_attach = on_attach,
    }

    -- ruby: use binary from gems, not a global one installed by mason
    require('lspconfig').standardrb.setup {
      cmd = { 'bin/standardrb', '--lsp' },
      capabilities = capabilities,
      on_attach = on_attach,
    }

    require('lspconfig').sourcekit.setup {
      -- cmd = 'xcrun sourcekit-lsp',
      filetypes = { 'swift', 'objective-c', 'objective-cpp' },
      capabilities = capabilities,
      on_attach = on_attach,
    }

    require('mason-lspconfig').setup_handlers {
      function(server_name)
        require('lspconfig')[server_name].setup {
          capabilities = capabilities,
          on_attach = on_attach,
          settings = servers[server_name],
          filetypes = (servers[server_name] or {}).filetypes,
        }
      end,
    }
  end,
}
