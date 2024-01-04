return {
	{
		'neovim/nvim-lspconfig',
		dependencies = {
			'j-hui/fidget.nvim',

			-- lsp completions
			'hrsh7th/cmp-nvim-lsp',
		},
		lazy = false,
		keys = {
			{ 'K', '<cmd>lua vim.lsp.buf.hover()<enter>' },
			{ '<LeftRelease>', '<cmd>lua vim.lsp.buf.hover()<enter>' },
			{ '<c-k>', '<cmd>lua vim.lsp.buf.signature_help()<enter>' },
			{ 'g[', '<cmd>lua vim.diagnostic.goto_prev()<enter>' },
			{ 'g]', '<cmd>lua vim.diagnostic.goto_next()<enter>' },
			{ 'ga', '<cmd>lua vim.lsp.buf.code_action()<enter>' },
			{ 'gr', '<cmd>lua vim.lsp.buf.rename()<enter>' },
		},
		config = function()
			local lsp = require('lspconfig')
			LspCapabilities = require('cmp_nvim_lsp').default_capabilities()

			local default_lsp_servers = { 'clangd', 'cmake', 'gopls', 'hls',  'pyright', 'tsserver', 'cssls', 'eslint', 'html', 'jsonls' }
			for _, s in ipairs(default_lsp_servers) do
				lsp[s].setup {
					capabilities = LspCapabilities,
				}
			end

			lsp.lua_ls.setup {
				capabilities = LspCapabilities,
				settings = {
					Lua = {
						diagnostics = {
							globals = { 'vim' }
						}
					}
				}
			}

			-- TODO: replace with
			-- vim.api.nvim_create_autocmd("BufWritePre", {
			-- 	pattern = "*.rs",
			-- 	callback = function()
			-- 	 vim.lsp.buf.formatting_sync(nil, 200)
			-- 	end,
			-- 	group = format_sync_grp,
			-- })

			local auto_fmt_ft = {
				'rs',
			}
			for _, ft in ipairs(auto_fmt_ft) do
				vim.cmd(string.format('autocmd BufWritePre *.%s lua vim.lsp.buf.format()', ft))
			end

			--[[ 
			-- autoformat in web projects
			for _, ft in ipairs({ 'js', 'ts', 'jsx', 'tsx', 'css', 'html' }) do
				vim.cmd(string.format('autocmd BufWritePre *.%s !prettier -w src/', ft))
			end
			]]
		end
	},

	{
		'hrsh7th/nvim-cmp',
		dependencies = {
			'hrsh7th/cmp-buffer',
			'hrsh7th/cmp-nvim-lsp',
			'hrsh7th/cmp-nvim-lsp-signature-help',
			'hrsh7th/cmp-nvim-lua',	-- nvim lua API
			'hrsh7th/cmp-path',
			'hrsh7th/cmp-vsnip',
			'hrsh7th/vim-vsnip',
			'hrsh7th/vim-vsnip-integ',
		},
		config = function()
			local cmp = require('cmp')
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
								-- vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<Tab>', true, true, true), 'nt', true)
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
						{ name = 'buffer' },
						{ name = 'nvim_lsp' },
						{ name = 'nvim_lsp_signature_help' },
						{ name = 'nvim_lua' },
						{ name = 'path' },
						{ name = 'vsnip' },
				}
			}
		end
	},

	{
		'simrat39/rust-tools.nvim',
		ft = "rust",
		config = function()
			require('rust-tools').setup {
				tools = {
					inlay_hints = {
						only_current_line = true,
					},
				},
				server = {
					capabilities = LspCapabilities,
					settings = {
						 ['rust-analyzer'] = {
							-- checkOnSave = {
							-- 	command = "clippy"
							-- },
							inlayHints = {
								closureReturnTypeHints = true,
							},
							imports = {
								prefix = "self",
							},
						}
					},
				}
			}
		end,
	},

	{
		 'mfussenegger/nvim-lint',
		 ft = "sh",
		 config = function()
			require('lint').linters_by_ft = {
				sh = { 'shellcheck' }
			}

			vim.api.nvim_create_autocmd({ "BufWritePost" }, {
				callback = function()
					require("lint").try_lint()
				end,
			})
		 end
	},

	{	-- lsp startup progress
		'j-hui/fidget.nvim',
		config = true,
	},

	-- {	-- lsp context
	-- 	'SmiteshP/nvim-navic',
	-- 	dependencies = 'neovim/nvim-lspconfig',
	-- 	lazy = true,
	-- 	init = function()
	-- 		vim.o.statusline = "%{%v:lua.require'nvim-navic'.get_location()%}"
	-- 	end,
	-- 	config = true,
	-- },

	--[[
	-- nvim api completions
	{
		'folke/neodev.nvim',
		-- this should be configured before lspconfig, so this can't be loaded lazily :(
		-- ft = 'lua',
		priority = 100,
		config = function()
			require('neodev').setup()
		end,
	}
	]]
}
