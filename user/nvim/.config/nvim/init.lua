-- lazy needs leader and some plugin needs termguicolors first
vim.g.mapleader = " "
vim.opt.termguicolors = true

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
print(lazypath)
vim.opt.rtp:prepend(lazypath)

--- plugins
require('lazy').setup('plugins')

local map = require('map')
map('i', 'jk', '<ESC>')
map('t', '<C-j><C-k>', '<C-\\><C-n>')
map('n', '<Leader>s', ':set spell!<enter>')

--- options
vim.opt.shortmess = vim.opt.shortmess + 'c' 	-- avoid showing short messages -- TODO: what short messages are you even talking about???
vim.opt.completeopt = {'menu', 'menuone', 'noselect'} -- TODO: mb add noinsert
vim.opt.signcolumn = 'yes'
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.mouse = 'a'
vim.opt.splitright = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.updatetime = 500
vim.opt.undofile = true
-- vim.opt.list = true
-- vim.opt.listchars = 'tab:| '
vim.opt.foldlevelstart = 99
vim.opt.cursorline = true

-- tabs
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = false
vim.opt.smarttab = false
vim.opt.smartindent = true

-- code
vim.cmd 'filetype plugin indent on'
vim.g.rust_recommended_style = 0	-- disable tabs in rust

--- ui
vim.wo.foldmethod = 'expr'

-- TODO: replace with vim.api.nvim_create_autocmd and user_command()

--- other
-- cmd 'command! Reload :source $MYVIMRC'
vim.cmd 'command! Cfg :edit $MYVIMRC'

-- highlight on yank
vim.cmd 'autocmd TextYankPost * lua vim.highlight.on_yank { timeout = 300 }'
