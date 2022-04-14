local cmd = vim.cmd
local opt = vim.opt
local g = vim.g
local wo = vim.wo

--- packer bootstrap
do
	local fn = vim.fn
	local install_path = fn.stdpath('data')..'/site/pack/packer/start/packer.nvim'
	if fn.empty(fn.glob(install_path)) > 0 then
		print('Bootstrapping Packer...')
		fn.system({'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path})
	end
end

--- plugins
require'packer'.startup(function(use)
	use 'wbthomason/packer.nvim'


	-- lsp
	use 'neovim/nvim-lspconfig'
	use 'hrsh7th/nvim-cmp'
	use 'hrsh7th/cmp-nvim-lsp'
	use 'hrsh7th/cmp-vsnip'
	-- use 'hrsh7th/cmp-path'
	use 'hrsh7th/cmp-buffer'
	use 'hrsh7th/vim-vsnip'
	use 'hrsh7th/vim-vsnip-integ'
	use 'simrat39/rust-tools.nvim'
	use 'mfussenegger/nvim-lint'


	-- ui
	use 'marko-cerovac/material.nvim'
	-- use 'shaunsingh/nord.nvim'

	use {
		'nvim-lualine/lualine.nvim',
		config = function()
			require'lualine'.setup {
				options = {
					theme = 'material-nvim',
				},
				sections = {
					-- disable {'encoding', 'fileformat', 'filetype'},
					lualine_x = {},
				},
			}
		end,
	}

	use {	-- lsp startup progress
		'j-hui/fidget.nvim',
		config = function()
			require'fidget'.setup {}
		end,
	}

	use {	-- file picker
		'nvim-telescope/telescope.nvim',
		requires = 'nvim-lua/plenary.nvim',
	}

	use {
		'ahmedkhalf/project.nvim',
		requires = 'telescope.nvim',
		after = 'telescope.nvim',
		config = function()
			require'project_nvim'.setup {
				exclude_dirs = {
					"~/.cargo/*",
					-- "/mnt/raid/coding/projects/pc/*",
					-- "/mnt/raid/coding/testing/pc/*",
				},
			}

			require'telescope'.load_extension 'projects'
		end,
	}

	use {
		'nvim-telescope/telescope-ui-select.nvim',
		requires = 'telescope.nvim',
		after = 'telescope.nvim',
		config = function()
			require'telescope'.load_extension 'ui-select'
		end,
	}

	use 'kyazdani42/nvim-web-devicons' -- icons

	use {
		'lewis6991/gitsigns.nvim',
		requires = 'nvim-lua/plenary.nvim',
		config = function()
			require'gitsigns'.setup {}
		end
	}

	use 'junegunn/goyo.vim'-- writer mode with :Goyo

	-- use {
	-- 	'nvim-lua/popup.nvim',
	-- 	requires = {'nvim-lua/plenary.nvim'},
	-- }

	use 'akinsho/toggleterm.nvim'

	-- other
	use 'Raimondi/delimitMate' -- automatically close brackets
	use 'tpope/vim-commentary' -- commenting out with gc
	use {
		'nvim-treesitter/nvim-treesitter',
		run = ':TSUpdate',
	}
	use {
		'David-Kunz/treesitter-unit',	-- select a treesitter unit, e.g. function
		requires = 'nvim-treesitter/nvim-treesitter',
		after = 'nvim-treesitter',
	}
	use 'tpope/vim-fugitive'	-- :Git commands
	use 'chaoren/vim-wordmotion'	-- CamelCase and snake_case movements with ',', e.g. ',w'
	use {
		'norcalli/nvim-colorizer.lua',
		config = function()
			require'colorizer'.setup {}
		end
	}
end)


--- keybinds
local function map(mode, key, command, opts)
	local options = {noremap = true}
	if opts then options = vim.tbl_extend('force', options, opts) end
	vim.api.nvim_set_keymap(mode, key, command, options)
end

g.mapleader = " "
map('i', 'jk', '<ESC>')
map('t', '<C-j><C-k>', '<C-\\><C-n>')
map('n', '<Leader>s', ':set spell!<enter>')
map('n', '<Leader>dd', '<cmd>Telescope git_files<enter>')
map('n', '<Leader>dD', '<cmd>Telescope find_files<enter>')
map('n', '<Leader>ds', '<cmd>Telescope lsp_document_symbols<enter>')
map('n', '<Leader>df', '<cmd>Telescope live_grep<enter>')
map('n', '<Leader>dt', '<cmd>Telescope treesitter<enter>')
map('n', '<Leader>dp', '<cmd>Telescope projects<enter>')
map('n', '<Leader>h', '<cmd>lua require"treesitter-unit".toggle_highlighting()<enter>')
map('n', 'K', '<cmd>lua vim.lsp.buf.hover()<enter>')
map('n', '<c-k>', '<cmd>lua vim.lsp.buf.signature_help()<enter>')
map('n', 'g[', '<cmd>lua vim.diagnostic.goto_prev()<enter>')
map('n', 'g]', '<cmd>lua vim.diagnostic.goto_next()<enter>')
map('n', 'ga', '<cmd>lua vim.lsp.buf.code_action()<enter>')
map('n', 'gr', '<cmd>lua vim.lsp.buf.rename()<enter>')
-- map('n', 'bb', '<cmd>lua require"dap".toggle_breakpoint()<enter>')
-- map('n', 'bc', '<cmd>lua require"dap".continue()<enter>')
-- map('n', 'bs', '<cmd>lua require"dap".step_over()<enter>')
-- map('n', 'bi', '<cmd>lua require"dap".step_into()<enter>')
-- TODO: tab binds


--- lsp
local lsp = require'lspconfig'
-- local on_attach = function(_, bufnr)
		--  local opts = { noremap=true, silent=true }
		--    vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<CR>', opts)
		--    vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gd', '<cmd>lua vim.lsp.buf.definition()<CR>', opts)
		--    vim.api.nvim_buf_set_keymap(bufnr, 'n', 'K', '<cmd>lua vim.lsp.buf.hover()<CR>', opts)
		--    vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)
		--    vim.api.nvim_buf_set_keymap(bufnr, 'n', '<C-k>', '<cmd>lua vim.lsp.buf.signature_help()<CR>', opts)
		--    vim.api.nvim_buf_set_keymap(bufnr, 'n', '<leader>wa', '<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>', opts)
		--    vim.api.nvim_buf_set_keymap(bufnr, 'n', '<leader>wr', '<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>', opts)
		--    vim.api.nvim_buf_set_keymap(bufnr, 'n', '<leader>wl', '<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>', opts)
		--    vim.api.nvim_buf_set_keymap(bufnr, 'n', '<leader>D', '<cmd>lua vim.lsp.buf.type_definition()<CR>', opts)
		--    vim.api.nvim_buf_set_keymap(bufnr, 'n', '<leader>rn', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)
		--    vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>', opts)
		--    vim.api.nvim_buf_set_keymap(bufnr, 'n', '<leader>ca', '<cmd>lua vim.lsp.buf.code_action()<CR>', opts)
		--    vim.api.nvim_buf_set_keymap(bufnr, 'n', '<leader>e', '<cmd>lua vim.diagnostic.open_float()<CR>', opts)
		--end

	-- TODO: menu?
	-- GotoMenu = function()
	-- 	require'popup'.create(
	-- 		{
	-- 			'Go to Declaration',
	-- 			'Go to Definition',
	-- 			'Go to Implementation',
	-- 		},
	-- 		{
	-- 			enter = true,
	-- 			cursorline = true,
	-- 			callback = function(_, sel)
	-- 				if sel == 'Go to Declaration' then
	-- 					print(1)
	-- 					-- vim.lsp.buf.declaration()
	-- 					vim.lsp.buf.hover()
	-- 				elseif sel == 'Go to Definition' then
	-- 					print(2)
	-- 					vim.lsp.buf.definition()
	-- 				elseif sel == 'Go to Implementation' then
	-- 					print(3)
	-- 					vim.lsp.buf.implementation()
	-- 				else
	-- 					print("WTF")
	-- 				end
	-- 			end,
	-- 		}
	-- 	)
	-- end

	-- mapb('gk', '<cmd>lua GotoMenu()<enter>')
	-- mapb('gd', '<cmd>lua vim.lsp.buf.declaration()<enter>')
	-- mapb('gD', '<cmd>lua vim.lsp.buf.definition()<enter>')
	-- mapb('1gD', '<cmd>lua vim.lsp.buf.type_definition()<enter>')
	-- mapb('gi', '<cmd>lua vim.lsp.buf.implementation()<enter>')
	-- mapb('gf', '<cmd>lua vim.lsp.buf.formatting()<enter>')
	-- mapb('gp', '<cmd>lua vim.diagnostic.setloclist()<enter>')
-- end
local capabilities  = require'cmp_nvim_lsp'.update_capabilities(vim.lsp.protocol.make_client_capabilities())

local cmp = require'cmp'
cmp.setup {
	  -- Enable LSP snippets
	snippet = {
		expand = function(args)
			vim.fn["vsnip#anonymous"](args.body)
		end,
	},
	mapping = {
		['<C-p>'] = cmp.mapping.select_prev_item(),
		['<C-n>'] = cmp.mapping.select_next_item(),
		-- FIXME
		['<S-Tab>'] = function(fallback)
			if cmp.visible() then
				if cmp.get_active_entry() then
					cmp.select_prev_item()
				else
					cmp.close()
					vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<Tab>', true, true, true), 'nt', true)
				end
				return
			end
			fallback()
		end,
		['<Tab>'] = cmp.mapping.select_next_item(),
		['<C-d>'] = cmp.mapping.scroll_docs(-4),
		['<C-f>'] = cmp.mapping.scroll_docs(4),
		['<C-Space>'] = cmp.mapping.complete(),
		['<C-e>'] = cmp.mapping.close(),
		['<CR>'] = cmp.mapping.confirm({
			behavior = cmp.ConfirmBehavior.Insert,
			select = true,
		}),
	},
	sources = {
			{ name = 'nvim_lsp' },
			{ name = 'vsnip' },
			{ name = 'buffer' },
			-- { name = 'path' },
	}
}

lsp.sumneko_lua.setup {
	-- on_attach = on_attach,
	capabilities = capabilities,
	settings = {
		Lua = {
			diagnostics = {
				globals = { 'vim' }
			}
		}
	}
}

lsp.ccls.setup {}
lsp.pyright.setup {}

require'rust-tools'.setup {
	server = {
		-- on_attach = on_attach,
		capabilities = capabilities,
		settings = {
			 ['rust-analyzer'] = {
                -- enable clippy on save
                checkOnSave = {
                    command = "clippy"
                },
				inlayHints = {
					closureReturnTypeHints = true,
				},
            }
		},
	}
}

require'lint'.linters_by_ft = {
	sh = { 'shellcheck' }
}
cmd('autocmd BufWritePost *.sh lua require"lint".try_lint()')

local auto_fmt_ft = {
	'rs',
}
for _, ft in ipairs(auto_fmt_ft) do
	cmd(string.format('autocmd BufWritePre *.%s lua vim.lsp.buf.formatting_sync(nil, 1000)', ft))
end


--- options
opt.completeopt = {'menu', 'menuone', 'noselect'} -- TODO: mb add noinsert
opt.signcolumn = 'yes'
opt.number = true
opt.mouse = 'a'
opt.splitright = true
opt.ignorecase = true
opt.smartcase = true
opt.updatetime = 500
opt.undofile = true
opt.list = true
opt.listchars = 'tab:| '
opt.foldlevelstart=99

-- tabs
opt.tabstop = 4
opt.shiftwidth = 4
opt.expandtab = false
opt.smarttab = false
opt.smartindent = true

-- code
cmd 'filetype plugin indent on'
g.rust_recommended_style = 0	-- disable tabs in rust

--- ui
g.material_style = 'deep ocean'
require'material'.setup {
	contrast = {
		sidebars = true,
		floating_windows = true,
	},
	contrast_windows = {
		"term",
		"toggleterm",
		"packer",
	},
	custom_highlights = {
		-- lighter comments
		Comment = { fg = '#686d82' },
	}
}
cmd 'colorscheme material'

g.goyo_width = 150

require'nvim-treesitter.configs'.setup {
	ensure_installed = 'maintained',

	highlight = {
		enable = true,
	}
}

wo.foldmethod = 'expr'
wo.foldexpr = 'nvim_treesitter#foldexpr()'

require'toggleterm'.setup {
	open_mapping = [[<c-\>]],
	size = function(term)
		if term.direction == 'vertical' then
			return vim.o.columns * 0.475
		elseif term.direction == 'horizontal' then
			return vim.o.lines * 0.3
		else
			return 20	-- fallback
		end
	end,
	direction = 'vertical',
	persist_size = false,

	-- NOTE: doesn't work for some reason
	shade_terminals = false,
}


--- other
cmd 'command! Reload :source $MYVIMRC'
cmd 'command! Cfg :edit $MYVIMRC'

-- highlight on yank
cmd 'autocmd TextYankPost * lua vim.highlight.on_yank { timeout = 300 }'
-- g.wordmotion_prefix = ','
