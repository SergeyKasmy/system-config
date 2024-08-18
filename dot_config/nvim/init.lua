map = vim.keymap.set
opt = vim.opt

-- lazy needs leader and some plugin needs termguicolors first
vim.g.mapleader = " "
opt.termguicolors = true

-- for bufferline
-- vim.opt.mousemoveevent = true

--- lazy bootstrap
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
opt.rtp:prepend(lazypath)

--- plugins
require('lazy').setup('plugins')

--- key binds
map('i', 'jk', '<ESC>')
map('t', '<C-j><C-k>', '<C-\\><C-n>')
map('n', '<Leader>s', ':set spell!<enter>')
map('n', 'g[', vim.diagnostic.goto_prev, { desc = "Prev diagnostic" })
map('n', 'g]', vim.diagnostic.goto_next, { desc = "Next diagnostic" })

--- options
opt.shortmess = opt.shortmess + 'c' 	-- avoid showing short messages -- TODO: what short messages are you even talking about???
opt.completeopt = {'menu', 'menuone', 'noselect'} -- TODO: mb add noinsert
opt.signcolumn = 'yes'
opt.number = true
opt.relativenumber = true
opt.mouse = 'a'
opt.splitright = true
opt.ignorecase = true
opt.smartcase = true
opt.updatetime = 500
opt.undofile = true
-- opt.list = true
-- opt.listchars = 'tab:| '
opt.foldlevelstart = 99
opt.cursorline = true

-- tabs
opt.tabstop = 4
opt.shiftwidth = 4
opt.expandtab = false
opt.smarttab = false
opt.smartindent = true

-- code
vim.g.rust_recommended_style = 0	-- disable tabs in rust

--- ui
vim.wo.foldmethod = 'expr'

-- highlight on yank
vim.api.nvim_create_autocmd('TextYankPost', {
	callback = function()
		vim.highlight.on_yank({ timeout = 300 })
	end
})
