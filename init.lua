--    LionyxML Config for:
--                                              
--       ████ ██████           █████      ██
--      ███████████             █████ 
--      █████████ ███████████████████ ███   ███████████
--     █████████  ███    █████████████ █████ ██████████████
--    █████████ ██████████ █████████ █████ █████ ████ █████
--  ███████████ ███    ███ █████████ █████ █████ ████ █████
-- ██████  █████████████████████ ████ █████ █████ ████ ██████
--
--
-- {{{ About this config
-- =============================================================================
--                                   INIT.LUA
-- =============================================================================
--
-- Neovim configuration file written in Lua, licensed under the GPL-2.0 license.
--
-- Author:        Rahul Martim Juliato <rahul.juliato@gmail.com>
-- Created:       2023-10-31
-- Last Modified: today? yestarday? tomorrow? (check github.com/lionyxml)
--
-- =============================================================================
--                                  NOTES
-- =============================================================================
--
-- This Neovim configuration started from kickstart.nvim
-- (https://github.com/mhinz/vim-startify) and has been extended with
-- additional customizations.
--
-- The configuration is provided under the terms of the GNU General Public
-- License, version 2 (GPL-2.0). You are free to copy, modify, and distribute
-- this configuration, provided you include this license notice.
--
-- For the full text of the GPL-2.0 license, please visit:
-- https://www.gnu.org/licenses/gpl-2.0.html
--
-- This configuration uses the "lazy" plugin manager for lazy-loading plugins.
-- For more information on "lazy," please refer to its documentation.
--
-- Make sure to check the documentation of plugins for additional settings.
--
-- =============================================================================
--                                HAPPY VIMMING!
-- =============================================================================
-- }}}
-- {{{ Early vim globals and options
vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

vim.o.termguicolors = true

-- FIXME: still not working with trouble.nvim and snacks.nvim
vim.o.winborder = "rounded" -- can be: single, double, rounded, solid, shadow

_G.my_diagnostic_symbols = {
	error = "󰅚 ",
	warn = "󰀪 ",
	hint = " ",
	info = " ",
}

-- }}}
-- {{{ Lazy Package Manager --- Bootloader & Plugins
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable",
		lazypath,
	})
end
vim.opt.rtp:prepend(lazypath)
--- }}}
require("lazy").setup({
	-- {{{ SNACKS                          UI & EDIT & TXT - A jack of all trades
	{
		"folke/snacks.nvim",
		priority = 1000,
		lazy = false,
		---@diagnostic disable-next-line: undefined-doc-name
		---@type snacks.Config
		opts = {
			bigfile = { enabled = true },
			dashboard = {
				enabled = true,
				preset = {
					header = [[
                                                                    
       ████ ██████           █████      ██                    
      ███████████             █████                            
      █████████ ███████████████████ ███   ███████████  
     █████████  ███    █████████████ █████ ██████████████  
    █████████ ██████████ █████████ █████ █████ ████ █████  
  ███████████ ███    ███ █████████ █████ █████ ████ █████ 
 ██████  █████████████████████ ████ █████ █████ ████ ██████]],
				},
				sections = {
					{ section = "header" },
					{ section = "startup" },
				},
			},
			explorer = { enabled = true },
			input = { enabled = true },
			picker = {
				enabled = true,
				sources = {
					explorer = {
						enabled = true,
						hidden = true,
						auto_close = false,
						layout = {
							auto_hide = { "input" },
						},
						win = {
							list = {
								keys = {
									---@diagnostic disable-next-line: assign-type-mismatch
									["O"] = { { "pick_win", "jump" }, mode = { "n", "i" } },
								},
							},
						},
					},
				},
			},
			notifier = { enabled = true },
			scope = { enabled = true },
			gitbrowse = {
				url_patterns = {
					["devrepo%.%w+"] = {
						branch = "/-/tree/{branch}",
						file = "/-/blob/{branch}/{file}#L{line_start}-L{line_end}",
						permalink = "/-/blob/{commit}/{file}#L{line_start}-L{line_end}",
						commit = "/-/commit/{commit}",
					},
				},
			},
		},
		keys = {
			{
				"<leader>sf",
				function()
					Snacks.picker.files()
				end,
				desc = "Search Files",
			},
			{
				"<leader><space>",
				function()
					Snacks.picker.buffers()
				end,
				desc = "Buffers",
			},
			{
				"<leader>sg",
				function()
					Snacks.picker.grep()
				end,
				desc = "Grep",
			},
			{
				"<leader>:",
				function()
					Snacks.picker.command_history()
				end,
				desc = "Command History",
			},
			{
				"<leader>nn",
				function()
					Snacks.picker.notifications()
				end,
				desc = "Notification History",
			},
			{
				"<leader>ee",
				function()
					Snacks.explorer()
				end,
				desc = "File [e]xplorer",
			},
			{
				"<leader>gb",
				function()
					Snacks.picker.git_branches()
				end,
				desc = "Git Branches",
			},
			{
				"<leader>gl",
				function()
					Snacks.picker.git_log()
				end,
				desc = "Git Log",
			},
			{
				"<leader>gL",
				function()
					Snacks.picker.git_log_line()
				end,
				desc = "Git Log Line",
			},
			{
				"<leader>gs",
				function()
					Snacks.picker.git_status()
				end,
				desc = "Git Status",
			},
			{
				"<leader>gS",
				function()
					Snacks.picker.git_stash()
				end,
				desc = "Git Stash",
			},
			{
				"<leader>gf",
				function()
					Snacks.picker.git_log_file()
				end,
				desc = "Git Log File",
			},
			{
				"<leader>sw",
				function()
					Snacks.picker.grep_word()
				end,
				desc = "Visual selection or word",
				mode = { "n", "x" },
			},
			{
				"<leader>sd",
				function()
					Snacks.picker.diagnostics()
				end,
				desc = "Diagnostics",
			},
			{
				"<leader>sD",
				function()
					Snacks.picker.diagnostics_buffer()
				end,
				desc = "Buffer Diagnostics",
			},
			{
				"<leader>sh",
				function()
					Snacks.picker.help()
				end,
				desc = "Help Pages",
			},
			{
				"<leader>si",
				function()
					Snacks.picker.icons()
				end,
				desc = "Icons",
			},
			{
				"<leader>sq",
				function()
					Snacks.picker.qflist()
				end,
				desc = "Quickfix List",
			},
			{
				"<leader>sR",
				function()
					Snacks.picker.resume()
				end,
				desc = "search [R]esume",
			},
			{
				"<leader>U",
				function()
					Snacks.picker.undo()
				end,
				desc = "[U]ndo History",
			},
			{
				"gd",
				function()
					Snacks.picker.lsp_definitions()
				end,
				desc = "Goto Definition",
			},
			{
				"gD",
				function()
					Snacks.picker.lsp_declarations()
				end,
				desc = "Goto Declaration",
			},
			{
				"gr",
				function()
					Snacks.picker.lsp_references()
				end,
				nowait = true,
				desc = "References",
			},
			{
				"gI",
				function()
					Snacks.picker.lsp_implementations()
				end,
				desc = "Goto Implementation",
			},
			{
				"gy",
				function()
					Snacks.picker.lsp_type_definitions()
				end,
				desc = "Goto T[y]pe Definition",
			},
			{
				"<leader>ss",
				function()
					Snacks.picker.lsp_symbols()
				end,
				desc = "LSP Symbols",
			},
			{
				"<leader>sS",
				function()
					Snacks.picker.lsp_workspace_symbols()
				end,
				desc = "LSP Workspace Symbols",
			},
			{
				"<leader>tz",
				function()
					Snacks.zen()
				end,
				desc = "Toggle [z]en Mode",
			},
			{
				"<leader>tZ",
				function()
					Snacks.zen.zoom()
				end,
				desc = "Toggle [Z]oom",
			},
			{
				"<leader>ts",
				function()
					Snacks.scratch()
				end,
				desc = "Toggle [s]cratch buffer",
			},
			{
				"<leader>S",
				function()
					Snacks.scratch.select()
				end,
				desc = "Select [S]cratch Buffer",
			},
			{
				"<leader>rf",
				function()
					Snacks.rename.rename_file()
				end,
				desc = "Rename [f]ile",
			},
			{
				"<leader>gB",
				function()
					Snacks.gitbrowse()
				end,
				desc = "Git Browse",
				mode = { "n", "v" },
			},
			{
				"<leader>gG",
				function()
					Snacks.lazygit()
				end,
				desc = "Lazygit",
			},
			{
				"<leader>nh",
				function()
					Snacks.notifier.hide()
				end,
				desc = "Dismiss All Notifications",
			},
		},
	},
	-- }}}
	-- {{{ LSPConfig                       CODE - LSP Configurations ans plugins
	{
		"neovim/nvim-lspconfig",
		dependencies = {
			-- Automatically install LSPs and related tools to stdpath for Neovim
			{ "williamboman/mason.nvim", config = true }, -- NOTE: Must be loaded before dependants
			"williamboman/mason-lspconfig.nvim",
			"WhoIsSethDaniel/mason-tool-installer.nvim",

			-- `neodev` configures Lua LSP for your Neovim config, runtime and plugins
			-- used for completion, annotations and signatures of Neovim apis
			{ "folke/neodev.nvim", opts = {} },
		},
		config = function()
			--  This function gets run when an LSP attaches to a particular buffer.
			--    That is to say, every time a new file is opened that is associated with
			--    an lsp (for example, opening `main.rs` is associated with `rust_analyzer`) this
			--    function will be executed to configure the current buffer
			vim.api.nvim_create_autocmd("LspAttach", {
				group = vim.api.nvim_create_augroup("kickstart-lsp-attach", { clear = true }),
				callback = function(event)
					local map = function(keys, func, desc)
						vim.keymap.set("n", keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
					end

					map("<leader>rn", vim.lsp.buf.rename, "re[n]ame symbol")

					map("<leader>ca", vim.lsp.buf.code_action, "code [a]ction")

					map("<leader>co", function()
						vim.lsp.buf.code_action({ context = { only = { "source.organizeImports" } }, apply = true })
					end, "code [o]rganize imports")

					map("K", vim.lsp.buf.hover, "Hover Documentation")

					local client = vim.lsp.get_client_by_id(event.data.client_id)
					if client and client.server_capabilities.documentHighlightProvider then
						local highlight_augroup =
							vim.api.nvim_create_augroup("kickstart-lsp-highlight", { clear = false })
						vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
							buffer = event.buf,
							group = highlight_augroup,
							callback = vim.lsp.buf.document_highlight,
						})

						vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
							buffer = event.buf,
							group = highlight_augroup,
							callback = vim.lsp.buf.clear_references,
						})

						vim.api.nvim_create_autocmd("LspDetach", {
							group = vim.api.nvim_create_augroup("kickstart-lsp-detach", { clear = true }),
							callback = function(event2)
								vim.lsp.buf.clear_references()
								vim.api.nvim_clear_autocmds({ group = "kickstart-lsp-highlight", buffer = event2.buf })
							end,
						})
					end

					if client and client.server_capabilities.inlayHintProvider and vim.lsp.inlay_hint then
						map("<leader>th", function()
							vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
						end, "Toggle inlay [h]ints")
					end
				end,
			})

			local capabilities = vim.lsp.protocol.make_client_capabilities()
			capabilities = vim.tbl_deep_extend("force", capabilities, require("cmp_nvim_lsp").default_capabilities())

			local servers = {
				-- ruff = {},
				pyright = {},
				gopls = {},
				prismals = {},
				-- htmx = {},
				bashls = {},
				rust_analyzer = {},
				rubocop = {},
				ruby_lsp = {},
				cssls = {},
				biome = { "typescript", "typescriptreact", "javascript", "javascriptreact" },
				ts_ls = {
					filetypes = { "typescript", "typescriptreact", "javascript", "javascriptreact" },
					-- TODO: this is not working yet for typescript
					settings = {
						typescript = {
							inlayHints = {
								includeInlayParameterNameHints = "all",
								includeInlayParameterNameHintsWhenArgumentMatchesName = false,
								includeInlayFunctionParameterTypeHints = true,
								includeInlayVariableTypeHints = true,
								includeInlayVariableTypeHintsWhenTypeMatchesName = false,
								includeInlayPropertyDeclarationTypeHints = true,
								includeInlayFunctionLikeReturnTypeHints = true,
								includeInlayEnumMemberValueHints = true,
							},
						},
					},
				},
				eslint = { filetypes = { "typescript", "typescriptreact", "javascript", "javascriptreact" } },
				tailwindcss = {},
				html = {},
				-- html = { filetypes = { 'html', 'twig', 'hbs'} },
				lua_ls = {
					Lua = {
						workspace = { checkThirdParty = false },
						telemetry = { enable = false },
						hint = { enable = true },
						diagnostics = {
							enable = true,
							globals = {
								"vim",
								"describe",
								"it",
								"before_each",
								"after_each",
								"packer_plugins",
								"MiniTest",
							},
							disable = { "missing-fields", "lowercase-global" },
						},
					},
				},
			}

			require("mason").setup({
				ui = {
					border = vim.o.winborder,
				},
			})

			local ensure_installed = vim.tbl_keys(servers or {})
			vim.list_extend(ensure_installed, {
				"stylua", -- Used to format Lua code
			})
			require("mason-tool-installer").setup({ ensure_installed = ensure_installed })

			require("mason-lspconfig").setup({
				handlers = {
					function(server_name)
						local server = servers[server_name] or {}
						-- This handles overriding only values explicitly passed
						-- by the server configuration above. Useful when disabling
						-- certain features of an LSP (for example, turning off formatting for tsserver)
						server.capabilities = vim.tbl_deep_extend("force", {}, capabilities, server.capabilities or {})
						require("lspconfig")[server_name].setup(server)
					end,
				},
			})
		end,
	},
	-- }}}
	-- {{{ Trouble                         CODE - Lists project errors
	{
		"folke/trouble.nvim",
		opts = {},
		cmd = "Trouble",
		keys = {
			{
				"<leader>xx",
				"<cmd>Trouble diagnostics toggle<cr>",
				desc = "Diagnostics (Trouble)",
			},
			{
				"<leader>xX",
				"<cmd>Trouble diagnostics toggle filter.buf=0<cr>",
				desc = "Buffer Diagnostics (Trouble)",
			},
			{
				"<leader>cs",
				"<cmd>Trouble symbols toggle focus=false<cr>",
				desc = "Symbols (Trouble)",
			},
			{
				"<leader>cl",
				"<cmd>Trouble lsp toggle focus=false win.position=right<cr>",
				desc = "LSP Definitions / references / ... (Trouble)",
			},
			{
				"<leader>xL",
				"<cmd>Trouble loclist toggle<cr>",
				desc = "Location List (Trouble)",
			},
			{
				"<leader>xQ",
				"<cmd>Trouble qflist toggle<cr>",
				desc = "Quickfix List (Trouble)",
			},
		},
	},
	-- }}}
	-- {{{ Nvim-Cmp                        EDIT - Autocompletion
	{
		"hrsh7th/nvim-cmp",
		event = "InsertEnter",
		dependencies = {
			{
				"L3MON4D3/LuaSnip",
				build = (function()
					-- Build Step is needed for regex support in snippets.
					-- This step is not supported in many windows environments.
					-- Remove the below condition to re-enable on windows.
					if vim.fn.has("win32") == 1 or vim.fn.executable("make") == 0 then
						return
					end
					return "make install_jsregexp"
				end)(),
				dependencies = {
					-- `friendly-snippets` contains a variety of premade snippets.
					--    See the README about individual language/framework/plugin snippets:
					--    https://github.com/rafamadriz/friendly-snippets
					{
						"rafamadriz/friendly-snippets",
						config = function()
							require("luasnip.loaders.from_vscode").lazy_load()
						end,
					},
				},
			},
			"saadparwaiz1/cmp_luasnip",
			"hrsh7th/cmp-nvim-lsp",
			"hrsh7th/cmp-path",
			"hrsh7th/cmp-cmdline",
			"onsails/lspkind.nvim",
		},
		config = function()
			-- See `:help cmp`
			local cmp = require("cmp")
			local luasnip = require("luasnip")
			luasnip.config.setup({})

			local lspkind = require("lspkind")

			-- `/` cmdline setup.
			cmp.setup.cmdline("/", {
				mapping = cmp.mapping.preset.cmdline(),
				sources = {
					{ name = "buffer" },
				},
			})

			-- `:` cmdline setup.
			cmp.setup.cmdline(":", {
				mapping = cmp.mapping.preset.cmdline(),
				sources = cmp.config.sources({
					{ name = "path" },
				}, {
					{
						name = "cmdline",
						option = {
							ignore_cmds = { "Man", "!" },
						},
					},
				}),
			})

			cmp.setup({
				snippet = {
					expand = function(args)
						luasnip.lsp_expand(args.body)
					end,
				},
				window = {
					completion = cmp.config.window.bordered(),
					documentation = cmp.config.window.bordered(),
				},
				---@diagnostic disable-next-line: missing-fields
				formatting = {
					format = lspkind.cmp_format({
						mode = "symbol",
						maxwidth = 50,
						ellipsis_char = "...",
						symbol_map = { Codeium = "" },
					}),
				},
				completion = { completeopt = "menu,menuone,noinsert" },

				mapping = cmp.mapping.preset.insert({
					["<C-n>"] = cmp.mapping.select_next_item(),
					["<C-p>"] = cmp.mapping.select_prev_item(),

					["<C-b>"] = cmp.mapping.scroll_docs(-4),
					["<C-f>"] = cmp.mapping.scroll_docs(4),

					["<C-y>"] = cmp.mapping.confirm({ select = true }),

					["<CR>"] = cmp.mapping.confirm({ select = true }),
					["<Tab>"] = cmp.mapping.select_next_item(),
				}),
				sources = {
					{ name = "nvim_lsp" },
					{ name = "luasnip" },
					{ name = "path" },
					{ name = "codeium" },
				},
			})
		end,
	},

	-- }}}
	-- {{{ Nvim-Autopairs                  EDIT - Automatically closes parens, breakets, etc.
	{
		"windwp/nvim-autopairs",
		event = "InsertEnter",
		opts = {},
	},
	-- }}}
	-- {{{ Nvim-Ts-Autotag                 EDIT - Automatically close tags on html, typescript, vue...
	{
		"windwp/nvim-ts-autotag",
		event = "VeryLazy",
		opts = {
			autotag = {
				enable = true,
			},
		},
	},
	--}}}
	-- {{{ Conform                         EDIT - The universal formatter wrapper
	{
		-- Formatter by filetype
		"stevearc/conform.nvim",
		event = { "BufReadPre", "BufNewFile" },
		config = function()
			local conform = require("conform")

			conform.setup({
				formatters_by_ft = {
					bash = { "shfmt" },
					javascript = { "prettier" },
					typescript = { "prettier" },
					javascriptreact = { "prettier" },
					typescriptreact = { "prettier" },
					svelte = { "prettier" },
					css = { "prettier" },
					html = { "prettier" },
					json = { "prettier" },
					yaml = { "prettier" },
					markdown = { "prettier" },
					graphql = { "prettier" },
					lua = { "stylua" },
					python = { "ruff" },
					go = { "gofmt" },
				},
				format_on_save = {
					lsp_fallback = true,
					async = false,
					timeout_ms = 5000,
				},
			})

			vim.keymap.set({ "n", "v" }, "<leader>mp", function()
				conform.format({
					lsp_fallback = true,
					async = false,
					timeout_ms = 5000,
				})
			end, { desc = "[p]rettier" })

			vim.api.nvim_create_user_command("FormatDisable", function(args)
				if args.bang then
					-- FormatDisable! will disable formatting just for this buffer
					vim.b.disable_autoformat = true
				else
					vim.g.disable_autoformat = true
				end
			end, {
				desc = "Disable autoformat-on-save",
				bang = true,
			})
			vim.api.nvim_create_user_command("FormatEnable", function()
				vim.b.disable_autoformat = false
				vim.g.disable_autoformat = false
			end, {
				desc = "Re-enable autoformat-on-save",
			})
		end,
	},
	-- }}}
	-- {{{ TS-Comments                     EDIT - Adds tree sitter context to nvim built-in commenter
	{
		"folke/ts-comments.nvim",
		opts = {},
		event = "VeryLazy",
		enabled = vim.fn.has("nvim-0.10.0") == 1,
	},
	-- }}}
	-- {{{ Mini                            EDIT - The Lua Modules library for Neovim
	{
		"echasnovski/mini.nvim",
		version = false,
		config = function()
			-- Better Around/Inside textobjects
			--
			-- Examples:
			--  - va)  - [V]isually select [A]round [)]paren
			--  - yinq - [Y]ank [I]nside [N]ext [Q]uote
			--  - ci'  - [C]hange [I]nside [']quote
			require("mini.ai").setup({ n_lines = 500 })

			-- Add/delete/replace surroundings (brackets, quotes, etc.)
			--
			-- - sa{   - [S]urround [A]dd { around visual selection
			-- - saiw) - [S]urround [A]dd [I]nner [W]ord [)]Paren
			-- - sd'   - [S]urround [D]elete [']quotes
			-- - sr)'  - [S]urround [R]eplace [)] [']
			require("mini.surround").setup()
		end,
	},
	-- }}}
	-- {{{ Yanky                           EDIT - Yank history
	{
		"gbprod/yanky.nvim",
		dependencies = {
			{ "kkharji/sqlite.lua" },
		},
		opts = {
			ring = { storage = "sqlite" },
		},
		keys = {
			{
				"<leader>p",
				"<cmd>YankyRingHistory<cr>",
				desc = "Open Yank History",
			},
		},
	},
	-- }}}
	-- {{{ UndoTree                        EDIT - Perfect pitch Undoing
	{
		"mbbill/undotree",
		config = function()
			vim.g.undotree_WindowLayout = 3 -- tree on the right
			vim.keymap.set("n", "<leader>u", function()
				vim.cmd.UndotreeToggle()
				vim.cmd.UndotreeFocus()
			end, { desc = "[u]ndo tree" })
		end,
	},
	-- }}}
	-- {{{ Codeium                         EDIT - Copilot like alternative
	{
		"Exafunction/windsurf.nvim",
		event = "VeryLazy",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"hrsh7th/nvim-cmp",
		},
		config = function()
			require("codeium").setup({})
			vim.api.nvim_set_keymap("n", "<leader>tC", ":Codeium Toggle<cr>", {
				desc = "Toggle [C]odium",
				noremap = true,
			})
		end,
	},
	-- }}}
	-- {{{ Oil-Nvim                        FILE - Dired for neovim
	{
		"stevearc/oil.nvim",
		opts = {
			columns = {
				"permissions",
				"size",
				"mtime",
				"icon",
			},
			delete_to_trash = true,
		},
		keys = {
			{
				"<leader>ed",
				"<cmd>Oil<CR>",
				desc = "Oil File Manager",
			},
		},
		dependencies = { { "echasnovski/mini.icons", opts = {} } },
		-- dependencies = { "nvim-tree/nvim-web-devicons" }, -- use if you prefer nvim-web-devicons
		-- Lazy loading is not recommended because it is very tricky to make it work correctly in all situations.
		lazy = false,
	},
	-- }}}
	-- {{{ Nvim-Spectre                    EDIT - For complex find and replace
	{
		"nvim-pack/nvim-spectre",
		keys = {
			{
				"<leader>sr",
				'<cmd>lua require("spectre").toggle()<CR>',
				desc = "Search and [r]eplace (Spectre)",
			},
		},
		dependencies = { "nvim-lua/plenary.nvim" },
	},
	-- }}}
	-- {{{ Org-mode                        TXT - Org-mode for Neovim
	{
		"nvim-orgmode/orgmode",
		event = "VeryLazy",
		ft = { "org" },
		config = function()
			-- Setup orgmode
			require("orgmode").setup({
				org_agenda_files = "~/orgfiles/**/*",
				org_default_notes_file = "~/orgfiles/refile.org",
			})
		end,
	},
	-- }}}
	-- {{{ Cloack-Nvim                     TXT - Hides secrets on env files
	{
		"laytan/cloak.nvim",
		config = function()
			vim.keymap.set("n", "<leader>tk", ":CloakToggle<CR>", { desc = "Toggle Cloa[k]", silent = true })

			require("cloak").setup({
				enabled = true,
				cloak_character = "*",
				highlight_group = "Comment",
				cloak_length = 20, -- Provide a number if you want to hide the true length of the value.
				try_all_patterns = true,
				cloak_telescope = false,
				cloak_on_leave = true,
				patterns = {
					{
						file_pattern = ".env*",
						cloak_pattern = "=.+",
						replace = nil,
					},
				},
			})
		end,
	},
	-- }}}
	-- {{{ Vim-Sleuth                      TXT - Detect tabstop and shiftwidth automatically
	{
		"tpope/vim-sleuth",
	},
	-- }}}
	-- {{{ Nvim-Treesitter-Context         TXT - Adds tree sitter context to the buffer
	{
		"nvim-treesitter/nvim-treesitter-context",
		opts = {
			enable = true, -- Defaults to disabled, use <leader>tc to toggle Context
		},
	},
	-- }}}
	-- {{{ Aerial                          TXT - The tree viewer for symbols
	{
		"stevearc/aerial.nvim",
		opts = {
			enabled = false, -- Defaults to disabled, use <leader>ta to toggle Aerial
		},
	},
	-- }}}
	-- {{{ Rainbow Delimiters              TXT - Colorize parentheses, brackets, etc
	{
		"HiPhish/rainbow-delimiters.nvim",
		config = function()
			require("rainbow-delimiters.setup").setup({
				query = {
					[""] = "rainbow-delimiters",
					lua = "rainbow-blocks",
					typescript = "rainbow-parens",
					tsx = "rainbow-parens",
				},
			})
		end,
	},
	-- }}}
	-- {{{ TreeSitter                      TXT - Highlight, edit and navigate code
	{
		-- Highlight, edit, and navigate code
		"nvim-treesitter/nvim-treesitter",

		config = function()
			vim.defer_fn(function()
				---@diagnostic disable-next-line: missing-fields
				require("nvim-treesitter.configs").setup({
					ensure_installed = {
						"regex",
						"c",
						"cpp",
						"go",
						"gomod",
						"lua",
						"python",
						"rust",
						"tsx",
						"javascript",
						"typescript",
						"vimdoc",
						"vim",
						"bash",
						"html",
						"prisma",
						"vue",
					},

					auto_install = false,

					highlight = { enable = true },
					indent = { enable = true },
					incremental_selection = {
						enable = true,
						keymaps = {
							init_selection = "<c-space>",
							node_incremental = "<c-space>",
							scope_incremental = "<c-s>",
							node_decremental = "<M-space>",
						},
					},
					textobjects = {
						select = {
							enable = true,
							lookahead = true, -- Automatically jump forward to textobj, similar to targets.vim
							keymaps = {
								["aa"] = "@parameter.outer",
								["ia"] = "@parameter.inner",
								["af"] = "@function.outer",
								["if"] = "@function.inner",
								["ac"] = "@class.outer",
								["ic"] = "@class.inner",
							},
						},
						move = {
							enable = true,
							set_jumps = true, -- whether to set jumps in the jumplist
							goto_next_start = {
								["]m"] = "@function.outer",
								["]]"] = "@class.outer",
							},
							goto_next_end = {
								["]M"] = "@function.outer",
								["]["] = "@class.outer",
							},
							goto_previous_start = {
								["[m"] = "@function.outer",
								["[["] = "@class.outer",
							},
							goto_previous_end = {
								["[M"] = "@function.outer",
								["[]"] = "@class.outer",
							},
						},
					},
				})
			end, 0)
		end,

		dependencies = {
			"nvim-treesitter/nvim-treesitter-textobjects",
		},
		build = ":TSUpdate",
	},
	-- }}}
	-- {{{ HL-Chunk                        TXT - Provides chunk/indent line + colors linum
	{
		"shellRaining/hlchunk.nvim",
		event = { "BufReadPre", "BufNewFile" },
		config = function()
			require("hlchunk").setup({
				indent = {
					enable = false,
					priority = 10,
					-- style = { vim.api.nvim_get_hl(0, { name = "Whitespace" }) },
					use_treesitter = false,
					chars = { "│" },
					ahead_lines = 5,
					delay = 100,
				},
				chunk = {
					enable = true,
					priority = 15,
					style = {
						{ fg = "#aab4f1" },
						{ fg = "#cd758f" },
					},
					use_treesitter = true,
					chars = {
						horizontal_line = "─",
						vertical_line = "│",
						left_top = "╭",
						left_bottom = "╰",
						right_arrow = "─",
					},
					textobject = "",
					max_file_size = 1024 * 1024,
					error_sign = true,
					-- animation related
					duration = 0,
					delay = 0,
				},
				line_num = {
					enable = true,
					style = "#7ba2e2",
					priority = 10,
					use_treesitter = true,
				},
			})
		end,
	},
	-- }}}
	-- {{{ TODO-Comments                   TXT - Highlights TODO HACK FIXME BUG ISSUE...
	{
		"folke/todo-comments.nvim",
		dependencies = { "nvim-lua/plenary.nvim" },
		opts = {},
	},
	-- }}}
	-- {{{ CCC                             TXT - Colorize color codes / Color picker
	{
		"uga-rosa/ccc.nvim",
		cmd = { "CccPick", "CccConvert", "CccHighlighterToggle" },
		config = function()
			local ccc = require("ccc")
			ccc.setup({
				inputs = {
					ccc.input.rgb,
					ccc.input.cmyk,
					ccc.input.hsl,
				},
				highlighter = {
					auto_enable = true,
					lsp = true,
				},
			})
		end,
		keys = {
			{ "<leader>cp", "<cmd>CccPick<cr>", desc = "Color [p]icker" },
			{ "<leader>cc", "<cmd>CccConvert<cr>", desc = "Color [c]ycle convert" },
			{ "<leader>ch", "<cmd>CccHighlighterToggle<cr>", desc = "Color [h]ighlighter" },
		},
	},
	-- }}}
	-- {{{ Image                           TXT - Shows images on markdown, org, etc.
	{
		"3rd/image.nvim",
		opts = {},
	},
	-- }}}
	-- {{{ Lualine                         UI - The cool statusline
	{
		"nvim-lualine/lualine.nvim",
		-- See `:help lualine.txt`
		opts = {
			options = {
				disabled_filetypes = {
					"NvimTree",
				},
				icons_enabled = true,
				component_separators = "",
				-- component_separators = { left = '', right = '' },
				section_separators = { left = "", right = "" },
				-- section_separators = { right = "" },
			},
			sections = {
				lualine_a = { { "mode", separator = { left = "" } } },
				lualine_b = {
					{
						"branch",
						icon = "󰘬",
						fmt = function(branch)
							local limit = 22
							return branch:sub(1, limit) .. (branch:len() > limit and "…" or "")
						end,
					},
					"diff",
					{
						"diagnostics",
						symbols = {
							hint = _G.my_diagnostic_symbols.hint,
							info = _G.my_diagnostic_symbols.info,
							warn = _G.my_diagnostic_symbols.warn,
							error = _G.my_diagnostic_symbols.error,
						},
					},
				},
				lualine_c = {
					{
						"filename",
						path = 4,
						symbols = {
							modified = " ●",
							alternate_file = "#",
							directory = "",
						},
					},
				},
				lualine_x = { "encoding", "fileformat", "filetype" },
				lualine_y = { "progress" },
				lualine_z = { { "location", separator = { right = "" } } },
			},
		},
	},
	-- }}}
	-- {{{ Noice                           UI - THE Beautiful UI for Neovim
	{
		"folke/noice.nvim",
		event = "VeryLazy",
		opts = {
			views = {
				cmdline_popup = {
					border = {
						style = vim.o.winborder,
					},
				},
				cmdline_popupmenu = {
					border = {
						style = vim.o.winborder,
					},
				},
				hover = {
					border = {
						style = vim.o.winborder,
					},
				},
				confirm = {
					border = {
						style = vim.o.winborder,
					},
				},
				popup = {
					border = {
						style = vim.o.winborder,
					},
				},
			},
			routes = { -- Hides written messages
				{
					filter = {
						event = "msg_show",
						kind = "",
						find = "written",
					},
					opts = { skip = true },
				},
			},
			lsp = {
				-- override markdown rendering so that **cmp** and other plugins use **Treesitter**
				override = {
					["vim.lsp.util.convert_input_to_markdown_lines"] = true,
					["vim.lsp.util.stylize_markdown"] = true,
					["cmp.entry.get_documentation"] = true, -- requires hrsh7th/nvim-cmp
				},
				hover = {
					silent = true,
				},
			},
			presets = {
				bottom_search = false, --        use a classic bottom cmdline for search
				command_palette = true, --       position the cmdline and popupmenu together
				long_message_to_split = true, -- long messages will be sent to a split
				inc_rename = true, --            enables an input dialog for inc-rename.nvim
				lsp_doc_border = true, --        add a border to hover docs and signature help
			},
		},
		keys = {
			{
				"<leader>snl",
				function()
					require("noice").cmd("last")
				end,
				desc = "Noice Last Message",
			},
			{
				"<leader>snh",
				function()
					require("noice").cmd("history")
				end,
				desc = "Noice History",
			},
			{
				"<leader>sna",
				function()
					require("noice").cmd("all")
				end,
				desc = "Noice All",
			},
			{
				"<c-n>",
				function()
					if not require("noice.lsp").scroll(4) then
						return "<c-f>"
					end
				end,
				silent = true,
				expr = true,
				desc = "Scroll forward",
				mode = { "i", "n", "s" },
			},
			{
				"<c-p>",
				function()
					if not require("noice.lsp").scroll(-4) then
						return "<c-b>"
					end
				end,
				silent = true,
				expr = true,
				desc = "Scroll backward",
				mode = { "i", "n", "s" },
			},
		},
		dependencies = {
			"MunifTanjim/nui.nvim",
			-- OPTIONAL:
			--   `nvim-notify` is only needed, if you want to use the notification view.
			--   If not available, we use `mini` as the fallback
			-- "rcarriga/nvim-notify",
		},
	},
	-- }}}
	-- {{{ Which-Key                       UI - The (another Emacs stolen) plugin that shows pending keybindings
	{
		"folke/which-key.nvim",
		event = "VeryLazy",
		config = function()
			local wk = require("which-key")

			wk.add({
				{ "<leader>0", group = "[0]x0 uploader" },
				{ "<leader>0_", hidden = true },
				{ "<leader>c", group = "[c]ode / [c]olor" },
				{ "<leader>c_", hidden = true },
				{ "<leader>d", group = "[d]ocument / [d]AP" },
				{ "<leader>d_", hidden = true },
				{ "<leader>e", group = "[e]xplorer" },
				{ "<leader>e_", hidden = true },
				{ "<leader>g", group = "[g]it" },
				{ "<leader>g_", hidden = true },
				{ "<leader>b", group = "[b]uffer" },
				{ "<leader>b_", hidden = true },
				{ "<leader>h", group = "[h]unks operations" },
				{ "<leader>h_", hidden = true },
				{ "<leader>m", group = "[m]ake it..." },
				{ "<leader>m_", hidden = true },
				{ "<leader>n", group = "[n]otifications" },
				{ "<leader>n_", hidden = true },
				{ "<leader>o", group = "[o]org mode" },
				{ "<leader>o_", hidden = true },
				{ "<leader>r", group = "[r]ename" },
				{ "<leader>r_", hidden = true },
				{ "<leader>s", group = "[s]earch" },
				{ "<leader>s_", hidden = true },
				{ "<leader>sn", group = "[n]oice" },
				{ "<leader>t", group = "[t]oggle" },
				{ "<leader>t_", hidden = true },
				{ "<leader>tl", ":set number! norelativenumber<cr>", desc = "Toggle [l]ine number" },
				{ "<leader>tr", ":set relativenumber!<cr>", desc = "Toggle [r]elative line number" },
				{ "<leader>W", group = "[W]orkspace" },
				{ "<leader>W_", hidden = true },
				{ "<leader>x", group = "[x] is Trouble" },
				{ "<leader>x_", hidden = true },
			})

			wk.setup({
				preset = "helix",
				win = {
					border = vim.o.winborder,
					padding = { 2, 2 },
					wo = {
						winblend = 0,
					},
				},
				layout = {
					height = { min = 4, max = 25 }, -- min and max height of the columns
					width = { min = 20, max = 50 }, -- min and max width of the columns
					spacing = 3, -- spacing between columns
				},
			})
		end,
	},
	-- }}}
	-- {{{ Bufferline                      UI - The cool tabs stylyst
	{
		"akinsho/bufferline.nvim",
		version = "*",
		config = function()
			vim.o.mousemoveevent = true

			require("bufferline").setup({
				options = {
					mode = "tabs", --                       :tabs! not buffers
					buffer_close_icon = "",
					show_close_icon = false, --             X on the most right
					show_buffer_close_icons = false, --     X on tab
					show_duplicate_prefix = false, --       on :tabs it is expected to have duplicates
					custom_filter = function(buf)
						return vim.bo[buf].filetype ~= "qf"
					end,
					diagnostics = false,
					right_mouse_command = nil,
					indicator_icon = "",
					separator_style = "thin", -- "slant" | "slope" | "thick" | "thin" | { " ", " "}
					max_name_length = 10,
					tab_size = 5,
					numbers = function(opts)
						return string.format("  %s", opts.ordinal)
					end,
					name_formatter = function()
						return ""
					end,

					modified_icon = " ●",
					offsets = {
						{
							filetype = "snacks_layout_box",
						},
					},
				},
				highlights = require("catppuccin.groups.integrations.bufferline").get({}),
			})
		end,
	},
	-- }}}
	-- {{{ Catppuccin                      UI - The Only and One Theme :)
	{
		-- Catppuccin Theme
		"catppuccin/nvim",
		name = "catppuccin",
		priority = 1000,
		opts = {
			-- color_overrides = {
			--   mocha = {
			--     base = "#000000",
			--   },
			-- },
			flavour = "mocha",
			transparent_background = true,
			integrations = {
				aerial = true,
				alpha = true,
				bufferline = false,
				cmp = true,
				dashboard = true,
				flash = true,
				gitsigns = true,
				headlines = true,
				illuminate = true,
				indent_blankline = { enabled = true },
				leap = true,
				lsp_trouble = true,
				mason = true,
				markdown = true,
				mini = {
					enabled = true,
					indentscope_color = "",
				},
				native_lsp = {
					enabled = true,
					underlines = {
						errors = { "undercurl" },
						hints = { "undercurl" },
						warnings = { "undercurl" },
						information = { "undercurl" },
					},
				},
				navic = { enabled = true, custom_bg = "lualine" },
				noice = true,
				notify = true,
				nvimtree = true,
				telescope = false,
				treesitter = true,
				treesitter_context = true,
				which_key = true,
				rainbow_delimiters = true,
				fidget = true,
				snacks = true,
			},
		},
	},
	-- }}}
	-- {{{ CURL.nvim                       UTIL - A curl interface
	{
		"oysandvik94/curl.nvim",
		cmd = { "CurlOpen" },
		dependencies = {
			"nvim-lua/plenary.nvim",
		},
		config = true,
	},
	-- }}}
	-- {{{ Nvim-Tmux-Navigator             UTIL - Integration with tmux
	--
	-- NOTE: you do have to make some config on the tmux side. This should
	--       be placed on your `tmux.conf`:
	--
	-- is_vim="ps -o state= -o comm= -t '#{pane_tty}' \
	--     | grep -iqE '^[^TXZ ]+ +(\\S+\\/)?g?(view|n?vim?x?)(diff)?$'"
	--
	-- bind-key -n 'C-h' if-shell "$is_vim" 'send-keys C-h' 'select-pane -L'
	-- bind-key -n 'C-j' if-shell "$is_vim" 'send-keys C-j' 'select-pane -D'
	-- bind-key -n 'C-k' if-shell "$is_vim" 'send-keys C-k' 'select-pane -U'
	-- bind-key -n 'C-l' if-shell "$is_vim" 'send-keys C-l' 'select-pane -R'
	--
	-- tmux_version='$(tmux -V | sed -En "s/^tmux ([0-9]+(.[0-9]+)?).*/\1/p")'
	--
	-- if-shell -b '[ "$(echo "$tmux_version < 3.0" | bc)" = 1 ]' \
	--     "bind-key -n 'C-\\' if-shell \"$is_vim\" 'send-keys C-\\'  'select-pane -l'"
	-- if-shell -b '[ "$(echo "$tmux_version >= 3.0" | bc)" = 1 ]' \
	--     "bind-key -n 'C-\\' if-shell \"$is_vim\" 'send-keys C-\\\\'  'select-pane -l'"
	--
	-- bind-key -n 'C-Space' if-shell "$is_vim" 'send-keys C-Space' 'select-pane -t:.+'
	--
	-- bind-key -T copy-mode-vi 'C-h' select-pane -L
	-- bind-key -T copy-mode-vi 'C-j' select-pane -D
	-- bind-key -T copy-mode-vi 'C-k' select-pane -U
	-- bind-key -T copy-mode-vi 'C-l' select-pane -R
	-- bind-key -T copy-mode-vi 'C-\' select-pane -l
	-- bind-key -T copy-mode-vi 'C-Space' select-pane -t:.+

	{
		"alexghergh/nvim-tmux-navigation",
		config = function()
			require("nvim-tmux-navigation").setup({
				disable_when_zoomed = false,
				keybindings = {
					left = "<C-h>",
					down = "<C-j>",
					up = "<C-k>",
					right = "<C-l>",
					-- last_active = "<C-\\>",
					-- next = "<C-Space>",
				},
			})
		end,
	},
	-- }}}
	-- {{{ Auto-Session                    UTIL - Automatically restores saved sessions
	{
		"rmagatti/auto-session",
		config = function()
			vim.o.sessionoptions = "blank,buffers,curdir,folds,help,tabpages,winsize,winpos,terminal,localoptions"

			local auto_session = require("auto-session")

			auto_session.setup({
				auto_session_enabled = true,
				auto_restore_enabled = true,
				auto_session_suppress_dirs = { "~/", "~/Dev/", "~/Downloads", "~/Documents", "~/Desktop/" },
				silent_restore = false,
			})

			local keymap = vim.keymap

			keymap.set("n", "<leader>Wr", "<cmd>SessionRestore<CR>", { desc = "Workspace [r]estore session for cwd" }) -- restore last workspace session for current directory
			keymap.set(
				"n",
				"<leader>Ws",
				"<cmd>SessionSave<CR>",
				{ desc = "Workspace [s]ave session for auto session root dir" }
			) -- save workspace session for current working directory
		end,
	},
	-- }}}
	-- {{{ Nvim-0x0                        UTIL - Paste text / files to 0x0.st
	{
		"LionyxML/nvim-0x0",
		opts = {
			-- base_url = "https://<your-0x0-instance>,/", -- only needed if you host your own 0x0 instance
			use_default_keymaps = true, -- Set to false if you want to define your own keymaps
		},
	},
	-- }}}
	-- {{{ Diffview                        VC - Diff visualizer
	{
		"sindrets/diffview.nvim",
		event = "VeryLazy",
		config = function()
			vim.keymap.set("n", "<leader>gd", function()
				if next(require("diffview.lib").views) == nil then
					vim.cmd("DiffviewOpen")
				else
					vim.cmd("DiffviewClose")
				end
			end, { desc = "Git [d]iff with diffview" })

			vim.keymap.set({ "n", "v" }, "<leader>gH", function()
				vim.cmd("DiffviewFileHistory")
			end, { desc = "Git file [H]istory" })

			local diffview = require("diffview")
			diffview.setup({
				hg_cmd = { "" },
				use_icons = false,
			})
		end,
		-- NOTE: waiting for https://github.com/sindrets/diffview.nvim/pull/571 so everything can be mini icons
		-- dependencies = { "nvim-tree/nvim-web-devicons" }, -- use if prefer nvim-web-devicons
	},
	-- }}},
	-- {{{ Gitsigns                        VC - Adds git gutter / hunk blame&diff
	{
		"lewis6991/gitsigns.nvim",
		opts = {
			signs = {
				add = { text = "┃" },
				change = { text = "┃" },
				delete = { text = "_" },
				topdelete = { text = "‾" },
				changedelete = { text = "~" },
				untracked = { text = "┆" },
			},
			signs_staged = {
				add = { text = "┃" },
				change = { text = "┃" },
				delete = { text = "_" },
				topdelete = { text = "‾" },
				changedelete = { text = "~" },
				untracked = { text = "┆" },
			},

			signs_staged_enabled = true,

			on_attach = function(bufnr)
				local gs = package.loaded.gitsigns

				local function map(mode, l, r, opts)
					opts = opts or {}
					opts.buffer = bufnr
					vim.keymap.set(mode, l, r, opts)
				end

				-- Navigation
				map("n", "]c", function()
					if vim.wo.diff then
						vim.cmd.normal({ "]c", bang = true })
					else
						gs.nav_hunk("next")
					end
				end)

				map("n", "[c", function()
					if vim.wo.diff then
						vim.cmd.normal({ "[c", bang = true })
					else
						gs.nav_hunk("prev")
					end
				end)

				-- Actions
				map({ "n", "v" }, "<leader>hs", ":Gitsigns stage_hunk<CR>", { desc = "Hunk [s]tage" })
				map({ "n", "v" }, "<leader>hr", ":Gitsigns reset_hunk<CR>", { desc = "Hunk [r]eset" })
				map("n", "<leader>hS", gs.stage_buffer, { desc = "[S]tage buffer" })
				map("n", "<leader>ha", gs.stage_hunk, { desc = "Stage [a] hunk" })
				map("n", "<leader>hu", gs.undo_stage_hunk, { desc = "[u]ndo stage hunk" })
				map("n", "<leader>hR", gs.reset_buffer, { desc = "[R]eset Buffer" })
				map("n", "<leader>hp", gs.preview_hunk, { desc = "[p]review hunk" })
				map("n", "<leader>hb", function()
					gs.blame_line({ full = true })
				end, { desc = "[b]lame Line" })
				map("n", "<leader>tB", gs.toggle_current_line_blame, { desc = "Toggle [B]lame line" })
				map("n", "<leader>hd", gs.diffthis, { desc = "Hunk [d]iff this" })
				map("n", "<leader>hD", function()
					gs.diffthis("~")
				end, { desc = "Hunk [D]iff this" })
			end,
		},
	},
	-- }}}
}, {
	-- {{{ Lazy Package Manager UI
	ui = {
		border = vim.o.winborder,
	},
	rocks = {
		enabled = false,
	},
	-- }}}
})

-- {{{ Classic VIM Configs             VIM - Options / Keymaps

-- Theme and transparency
vim.cmd.colorscheme("catppuccin")
vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
vim.api.nvim_set_hl(0, "NormalNC", { bg = "none" })
-- vim.api.nvim_set_hl(0, "EndOfBuffer", { bg = "none" }) -- this makes ~ visible, I don't like it

-- Basics
vim.wo.number = true
vim.o.relativenumber = true -- Toggle with <leader>tr
vim.o.showtabline = 0 --       Toggle Tabs with <leader>tt
vim.o.scrolloff = 8
vim.o.sidescrolloff = 8
vim.o.cursorline = true

-- Identation
vim.o.tabstop = 2
vim.o.shiftwidth = 2
vim.o.softtabstop = 2
vim.o.expandtab = true
vim.o.smartindent = true
vim.o.autoindent = true
vim.o.breakindent = true

-- Search settings
vim.o.hlsearch = true
vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.incsearch = true

-- File handling
vim.o.undofile = true
vim.o.backup = false
vim.o.writebackup = false
vim.o.autoread = true
vim.o.autowrite = false
vim.o.updatetime = 250
vim.o.timeoutlen = 1000
vim.o.swapfile = false

-- Visual settings
vim.wo.signcolumn = "yes"
vim.o.completeopt = "menuone,noinsert,noselect"
vim.o.showmatch = true
vim.o.wrap = false
vim.o.laststatus = 3
vim.opt.spelllang = { "en", "pt_br" }
vim.o.spell = false
vim.opt.fillchars:append({ fold = " " })
vim.o.pumheight = 0
vim.o.pumblend = 0
vim.o.winblend = 0

-- Split behaviour
vim.o.splitright = true
vim.o.splitbelow = true

-- Behaviour settings
vim.o.mouse = "a"
vim.o.clipboard = "unnamedplus"
vim.o.backspace = "indent,eol,start" -- Allow backspace on ident
vim.o.encoding = "UTF-8"
vim.o.errorbells = false
vim.o.autochdir = false -- While nice for :e ... commands, explorer also changes chdir, bummer...

-- Keybindings
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<cr>")
vim.keymap.set("i", "jj", "<Esc>")

vim.keymap.set("n", "n", "nzzzv", { desc = "Next search result (centered)" })
vim.keymap.set("n", "N", "Nzzzv", { desc = "Previous search result (centered)" })

vim.keymap.set({ "n", "v" }, "<C-d>", "<C-d>zz", { silent = true })
vim.keymap.set({ "n", "v" }, "<C-u>", "<C-u>zz", { silent = true })

vim.keymap.set("n", "<A-j>", ":m .+1<CR>==", { desc = "Move line down" })
vim.keymap.set("n", "<A-k>", ":m .-2<CR>==", { desc = "Move line up" })
vim.keymap.set("v", "<A-j>", ":m '>+1<CR>gv=gv", { desc = "Move selection down" })
vim.keymap.set("v", "<A-k>", ":m '<-2<CR>gv=gv", { desc = "Move selection up" })

vim.keymap.set("n", "k", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
vim.keymap.set("n", "j", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

vim.keymap.set("v", "<", "<gv", { desc = "Indent left and reselect" })
vim.keymap.set("v", ">", ">gv", { desc = "Indent right and reselect" })

vim.keymap.set("n", "<S-l>", ":bnext<CR>", { desc = "Next buffer", silent = true })
vim.keymap.set("n", "<S-h>", ":bprev<CR>", { desc = "Previous buffer", silent = true })
vim.keymap.set("n", "]b", ":bnext<CR>", { desc = "Next buffer", silent = true })
vim.keymap.set("n", "[b", ":bprev<CR>", { desc = "Previous buffer", silent = true })

vim.keymap.set("n", "]q", ":cnext<CR>", { desc = "Next quickfix item", silent = true })
vim.keymap.set("n", "[q", ":cprev<CR>", { desc = "Previous quickfix item", silent = true })

vim.keymap.set("n", "]t", ":tabnext<CR>", { desc = "Next tab", silent = true })
vim.keymap.set("n", "[t", ":tabprevious<CR>", { desc = "Previous tab", silent = true })

vim.keymap.set("n", "[d", function()
	vim.diagnostic.jump({ count = -1, float = true })
end, { desc = "Go to previous diagnostic message" })
vim.keymap.set("n", "]d", function()
	vim.diagnostic.jump({ count = 1, float = true })
end, { desc = "Go to next diagnostic message" })

vim.keymap.set("n", "<leader>dm", vim.diagnostic.open_float, { desc = "Open floating diagnostic [m]essage" })

vim.keymap.set("n", "<leader>ta", "<cmd>AerialToggle!<CR>", { desc = "Toggle [a]erial" })
vim.keymap.set("n", "<leader>tc", "<cmd>TSContextToggle<CR>", { desc = "Toggle treesitter [c]ontext" })
vim.keymap.set("n", "<leader>tI", "<cmd>IndentationLineToggle<CR>", { desc = "Toggle [I]ndent line" })

vim.keymap.set("n", "<leader>ti", function()
	local virtual_text = vim.diagnostic.config().virtual_text
	vim.diagnostic.config({ virtual_text = not virtual_text })
end, { desc = "Toggle [i]nline diagnostics" })

vim.keymap.set("n", "<leader>td", function()
	vim.diagnostic.enable(not vim.diagnostic.is_enabled())
end, { desc = "Toggle [d]iagnostics" })

vim.keymap.set("n", "<leader>tt", function()
	if vim.o.showtabline == 2 then
		vim.o.showtabline = 0
	else
		vim.o.showtabline = 2
	end
end, { desc = "Toggle [t]abs" })

vim.keymap.set("n", "<leader>bx", ":bd<CR>", { desc = "Close buffer", silent = true })
vim.keymap.set("n", "<leader>bX", ":bufdo bd<CR>", { desc = "Close all buffers", silent = true })

vim.keymap.set({ "n", "v" }, "<leader>L", ":Lazy<CR>", { desc = "[L]azy", silent = true })
vim.keymap.set({ "n", "v" }, "<leader>M", ":Mason<CR>", { desc = "[M]ason", silent = true })
vim.keymap.set({ "n", "v" }, "<leader>C", ":CurlOpen<CR>", { desc = "[C]url", silent = true })

vim.keymap.set({ "n", "v" }, "<leader>w", ":w<CR>", { desc = "[w]rite", silent = true })
vim.keymap.set({ "n", "v" }, "<leader>q", ":q<CR>", { desc = "[q]quit", silent = true })
vim.keymap.set({ "n", "v" }, "<leader>Q", ":qa<CR>", { desc = "[q]quit all", silent = true })

local highlight_group = vim.api.nvim_create_augroup("YankHighlight", { clear = true })
vim.api.nvim_create_autocmd("TextYankPost", {
	callback = function()
		vim.highlight.on_yank()
	end,
	group = highlight_group,
	pattern = "*",
})

vim.diagnostic.config({
	float = { border = vim.o.winborder },
	signs = {
		text = {
			[vim.diagnostic.severity.ERROR] = _G.my_diagnostic_symbols.error,
			[vim.diagnostic.severity.WARN] = _G.my_diagnostic_symbols.warn,
			[vim.diagnostic.severity.HINT] = _G.my_diagnostic_symbols.hint,
			[vim.diagnostic.severity.INFO] = _G.my_diagnostic_symbols.info,
		},
	},
})

--- }}}
-- vim: ts=2 sts=2 sw=2 et fileencoding=utf-8:foldmethod=marker
