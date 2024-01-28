-- See `:help vim.o`

-- disable netrw at the very start of your init.lua
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- Enable mouse mode
vim.o.mouse = 'a'

-- NOTE: You should make sure your terminal supports this
vim.o.termguicolors = true

vim.o.guicursor = ''

vim.o.nu = true
vim.o.relativenumber = true

vim.o.tabstop = 2
vim.o.softtabstop = 2
vim.o.shiftwidth = 2
vim.o.expandtab = true

vim.o.smartindent = true

vim.o.wrap = false

vim.o.swapfile = false
vim.o.backup = false
vim.o.undodir = os.getenv 'HOME' .. '/.vim/undodir'
vim.o.undofile = true

vim.o.hlsearch = false
vim.o.incsearch = true

vim.o.termguicolors = true

vim.o.scrolloff = 8
vim.o.signcolumn = 'yes'
-- vim.o.isfname:append("@-@")

vim.o.updatetime = 50

-- vim.o.colorcolumn = "80"

-- share status+cmd line
vim.o.cmdheight = 0
