return {
	{
		'neovim/nvim-lspconfig',
		dependencies = {
			-- lsp startup progress
			'j-hui/fidget.nvim',

			-- lsp completions
			'hrsh7th/cmp-nvim-lsp',
		},
		lazy = false,
		config = function()
			-- when attached to an LSP server: change binds to add LSP actions and enable inlay hints
			vim.api.nvim_create_autocmd('LspAttach', {
				callback = function(args)
					map('n', '<C-k>', vim.lsp.buf.signature_help, { desc = "LSP: Signature help" })
					map('n', 'K', vim.lsp.buf.hover, { desc = "LSP: Hover Info" })
					map('n', '<LeftRelease>', vim.lsp.buf.hover, { desc = "LSP: Hover info" })
					map('n', '<Leader>a', vim.lsp.buf.code_action, { desc = "LSP: Code action" })
					map('n', '<Leader>r', vim.lsp.buf.rename, { desc = "LSP: Rename item under cursor" })
					map('n', '<Leader>f', vim.lsp.buf.format, { desc = "LSP: Format buffer" })

					local client = vim.lsp.get_client_by_id(args.data.client_id)

					if client.server_capabilities.inlayHintProvider and vim.lsp.inlay_hint ~= nil then
						print(args.buf)
						vim.lsp.inlay_hint.enable(true, { buffnr = args.buf })
						map('n', '<Leader>i',
							function()
								vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = 0 }),
									{ bufnr = 0 })
							end, { desc = "LSP: Toggle inlay hints" })
					end
				end
			})

			local lsp = require('lspconfig')
			local lsp_capabilities = require('cmp_nvim_lsp').default_capabilities()

			-- servers that don't require any custom configuration
			local common_servers = {
				'clangd',
				'cmake',
				'cssls',
				'eslint',
				'gopls',
				'hls',
				'html',
				'jsonls',
				'pyright',
				'tsserver',
			}

			for _, server in ipairs(common_servers) do
				lsp[server].setup {
					capabilities = lsp_capabilities,
				}
			end

			lsp.lua_ls.setup {
				capabilities = lsp_capabilities,
				on_init = function(client)
					local path = client.workspace_folders[1].name

					-- if editing nvim config files, add vim runtime library to the library path
					if vim.endswith(path, '/nvim/lua/') then
						client.config.settings = vim.tbl_deep_extend('force', client.config.settings, {
							Lua = {
								runtime = {
									-- Tell the language server which version of Lua you're using
									-- (most likely LuaJIT in the case of Neovim)
									version = 'LuaJIT'
								},
								-- Make the server aware of Neovim runtime files
								workspace = {
									checkThirdParty = false,
									--[[	just the vim runtime
								library = {
									vim.env.VIMRUNTIME
								}
								]]
									-- or everything, including plugins
									library = vim.api.nvim_get_runtime_file("", true),
								}
							}
						})

						client.notify("workspace/didChangeConfiguration", { settings = client.config.settings })
					end
					return true
				end,
			}

			vim.api.nvim_create_augroup('lsp-format', { clear = false })

			-- autoformat on save for some specific filetypes using lsp formatter
			for _, ft in ipairs({ 'rs' }) do
				vim.api.nvim_create_autocmd("BufWritePre", {
					pattern = string.format('*.%s', ft),
					callback = function() 
						vim.lsp.buf.format()
					end,
					group = 'lsp-format',
					desc = string.format('Format *.%s files', ft)
				})
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
		"williamboman/mason.nvim",
		config = true,
	},

	{
		'hrsh7th/nvim-cmp',
		dependencies = {
			'hrsh7th/cmp-buffer',
			'hrsh7th/cmp-nvim-lsp',
			'hrsh7th/cmp-nvim-lsp-signature-help',
			'hrsh7th/cmp-nvim-lua', -- nvim lua API
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
		'mrcjkb/rustaceanvim',
		version = '^5',
		ft = { 'rust' },
		config = function()
			vim.g.rustaceanvim = {
				server = {
					default_settings = {
						['rust_analyzer'] = {
							checkOnSave = {
								command = "clippy"
							},
							inlayHints = {
								closureReturnTypeHints = true,
							},
							imports = {
								prefix = "self",
							},
						}
					}
				}
			}

			-- rebind J to use structured joining instead
			map({ 'n', 'v' }, 'J', '<cmd>RustLsp joinLines<enter>', { desc = "Rust: structurally join lines" })
			map('n', '<leader>mu', '<cmd>RustLsp moveItem up<enter>', { desc = "Rust: move item up" })
			map('n', '<leader>md', '<cmd>RustLsp moveItem up<enter>', { desc = "Rust: move item down" })
		end,
	},

	{
		'mfussenegger/nvim-lint',
		ft = "sh",
		config = function()
			require('lint').linters_by_ft = {
				sh = { 'shellcheck' }
			}

			vim.api.nvim_create_autocmd("BufWritePost", {
				callback = function()
					require("lint").try_lint()
				end,
			})
		end
	},

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

	{
		'j-hui/fidget.nvim',
		config = true,
	},

	--[[
	{
		'https://git.sr.ht/~whynothugo/lsp_lines.nvim',
		config = function()
			vim.diagnostic.config({ virtual_text = false })
			require('lsp_lines').setup()
			map('n', '<Leader>l', function()
					require('lsp_lines').toggle()
				end,
				{ desc = "Toggle lsp_lines" })
		end,
	},
	--]]
}
