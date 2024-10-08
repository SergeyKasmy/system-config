return {
	{
		'marko-cerovac/material.nvim',
		lazy = false,
		priority = 1000,
		opts = {
			plugins = {
				"gitsigns",
				"nvim-cmp",
				"telescope",
			},
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
		},
		init = function()
			vim.g.material_style = 'deep ocean'
		end,
		config = function()
			vim.cmd 'colorscheme material'
			vim.cmd 'highlight IlluminatedWordText guibg=#1F2233'
			vim.cmd 'highlight IlluminatedWordRead guibg=#1F2233'
			vim.cmd 'highlight IlluminatedWordWrite guibg=#1F2233'
		end
	},

	{
		'nvim-lualine/lualine.nvim',
		dependencies = {
			'nvim-tree/nvim-web-devicons',
		},
		opts = {
			options = {
				theme = 'material',
			},
			sections = {
				--[[
				-- disable 'filename'
				lualine_c = {},
				]]

				-- disable {'encoding', 'fileformat', 'filetype'},
				lualine_x = {},
			},
		}
	},


	{	-- file picker
		'nvim-telescope/telescope.nvim',
		dependencies = {
			'nvim-lua/plenary.nvim',
			'nvim-tree/nvim-web-devicons',
		},
		keys = {
			{ '<Leader>dd', '<cmd>Telescope git_files<enter>', desc = "Telescope: View non-git-ignored files" },
			{ '<Leader>dD', '<cmd>Telescope find_files<enter>', desc = "Telescope: View all files" },
			{ '<Leader>ds', '<cmd>Telescope lsp_document_symbols<enter>', desc = "Telescope: View LSP symbols" },
			{ '<Leader>de', '<cmd>Telescope diagnostics<enter>', desc = "Telescope: View all diagnostics" },
			{ '<Leader>df', '<cmd>Telescope live_grep<enter>', desc = "Telescope: Grep all files" },
			{ '<Leader>dt', '<cmd>Telescope treesitter<enter>', desc = "Telescope: View all tree-sitter items" },
			{ '<Leader>dp', '<cmd>Telescope projects<enter>', desc = "Telescope: View all projects" },
		},
		config = true,
	},

	{
		'nvim-telescope/telescope-ui-select.nvim',
		dependencies = 'telescope.nvim',
		config = function()
			require('telescope').load_extension('ui-select')
		end,
	},

	{
		'folke/which-key.nvim',
		config = function()
			vim.o.timeout = true
			vim.o.timeoutlen = 300

			require('which-key').setup()
		end
	},

	{	-- highlight other uses of the word under the cursor
		'RRethy/vim-illuminate',
		config = function()
			require('illuminate').configure {
				providers = {
					-- Disable LSP providers to avoid waiting for it for highlighting. treesitter is good enough
					-- 'lsp',
					'treesitter',
					'regex',
				}
			}
		end
	},

	{
		'nvim-tree/nvim-tree.lua',
		dependencies = 'nvim-tree/nvim-web-devicons',
		cmd = 'NvimTreeToggle',
		keys = {
			{ '<Leader>e', '<cmd>NvimTreeToggle<enter>', desc = "NvimTree: Toggle" }
		},
		config = function()
			require('nvim-tree').setup {
				on_attach = function(bufnr)
					local api = require('nvim-tree.api')

					api.config.mappings.default_on_attach(bufnr)

					local opts = function(desc)
						return { desc = 'nvim-tree: ' .. desc, buffer = bufnr, silent = true, nowait = true }
					end

					map('n', 'l', api.node.open.edit, opts('Open'))
					map('n', 'h', api.node.navigate.parent_close, opts('Close Directory'))
					map('n', 'v', api.node.open.vertical, opts('Open: Vertical Split'))
					map('n', 'C', api.tree.change_root_to_node, opts('cd'))
				end
			}
		end,
	},

	--[[
	{
		'akinsho/bufferline.nvim',
		config = true,
		dependencies = 'nvim-tree/nvim-web-devicons',
		opts = {
			options = {
				hover = {
					enabled = true,
					delay = 200,
					reveal = {'close'}
				}
			}
		},
	},
	]]

	{
		'lewis6991/gitsigns.nvim',
		dependencies = 'nvim-lua/plenary.nvim',
		config = true,
	},

	{
		"nvim-zh/colorful-winsep.nvim",
		config = true,
	},

	{	-- improve focus
		'Pocco81/true-zen.nvim',
		config = true,
		cmd = {
			'TZAtaraxis',
			'TZFocus',
			'TZNarrow',
			'TZMinimalist'
		},
	},

	{
		'akinsho/toggleterm.nvim',
		keys = { [[<c-\>]] },
		opts = {
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
	},

	-- replace with windwp/nvim-autopairs
	'Raimondi/delimitMate', -- automatically close brackets

	{
		'numToStr/Comment.nvim',
		keys = {
			{ 'gc', mode = { 'n', 'v' } },
			{ 'gb', mode = { 'n', 'v' } },
		},
		config = true,
	},

	{
		'nvim-treesitter/nvim-treesitter',
		build = ':TSUpdate',
		config = function()
			vim.wo.foldexpr = 'nvim_treesitter#foldexpr()'

			require('nvim-treesitter.configs').setup {
				ensure_installed = 'all',

				highlight = {
					enable = true,
				}
			}
		end
	},

	{	-- select a treesitter unit, e.g. function
		'David-Kunz/treesitter-unit',
		dependencies = 'nvim-treesitter/nvim-treesitter',
		keys = {
			{ '<Leader>h', '<cmd>lua require"treesitter-unit".toggle_highlighting()<enter>', desc = "Highlight current tree-sitter unit" }
		},
	},

	{
		'nvim-treesitter/nvim-treesitter-context',
		config = true,
	},

	{	-- :Git commands
		'tpope/vim-fugitive',
		event = "VeryLazy",
	},

	{	-- CamelCase and snake_case movements with ',', e.g. ',w'
		'chaoren/vim-wordmotion',
		event = "VeryLazy",
	},

	{
		'norcalli/nvim-colorizer.lua',
		event = "VeryLazy",
		config = true,
	},

	{
		'kylechui/nvim-surround',
		event = "VeryLazy",
		config = true,
	},

	"lukas-reineke/indent-blankline.nvim",

	{
		'stevearc/oil.nvim',
		opts = {
			default_file_explorer = false,
		},
		dependencies = { "nvim-tree/nvim-web-devicons" },
	},
}
