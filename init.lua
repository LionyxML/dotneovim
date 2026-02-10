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
vim.o.winborder = "rounded" -- can be: single, double, rounded, solid, shadow
vim.o.termguicolors = true
local use_nerd_icons = true
local use_special_chars = true
local custom_diagnostic_symbols = use_nerd_icons
		and {
			error = "󰅚 ",
			warn = "󰀪 ",
			hint = " ",
			info = " ",
		}
	or {
		error = "E",
		warn = "W",
		hint = "H",
		info = "I",
	}

-- Global helper functions
local unpack = table.unpack or unpack

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

					map("<leader>ln", vim.lsp.buf.rename, "re[n]ame")

					map("<leader>la", vim.lsp.buf.code_action, "code [a]ction")

					map("<leader>lo", function()
						vim.lsp.buf.code_action({ context = { only = { "source.organizeImports" } }, apply = true })
					end, "[o]rganize imports")

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
				-- rubocop = {},
				ruby_lsp = {},
				jsonls = {},
				cssls = {},
				somesass_ls = { "scss", "sass" },
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

			-- NOTE: kepp an eye on:
			-- https://github.com/nvim-lua/kickstart.nvim/pull/1663
			-- https://github.com/nvim-lua/kickstart.nvim/pull/1590

			-- The following loop will configure each server with the capabilities we defined above.
			-- This will ensure that all servers have the same base configuration, but also
			-- allow for server-specific overrides.
			for server_name, server_config in pairs(servers) do
				server_config.capabilities =
					vim.tbl_deep_extend("force", {}, capabilities, server_config.capabilities or {})
				vim.lsp.config(server_name, server_config)
				vim.lsp.enable(server_name)
			end
		end,
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
			end, { desc = "[p]rettify" })

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
	-- {{{ Mini                            EDIT - The Lua Modules library for Neovim
	{
		"nvim-mini/mini.nvim",
		version = false,
		config = function()
			-- Statusline
			require("mini.statusline").setup({ use_icons = use_nerd_icons })

			-- Better Around/Inside textobjects
			--
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

			-- Nice notifications on top right
			require("mini.notify").setup()

			vim.keymap.set("n", "<leader>nh", "<Cmd>lua MiniNotify.show_history()<CR>", {
				desc = "Notification history",
			})

			-- Nice notifications on top right
			require("mini.files").setup()
			vim.keymap.set("n", "<leader>ee", "<Cmd>lua MiniFiles.open()<CR>", { desc = "[e]xplore", silent = true })

			-- Pickers
			require("mini.pick").setup()
			vim.keymap.set("n", "<leader>fb", "<Cmd>Pick buffers<CR>", { desc = "[b]uffers", silent = true })
			vim.keymap.set("n", "<leader>ff", "<Cmd>Pick files<CR>", { desc = "[f]iles", silent = true })
			vim.keymap.set("n", "<leader>fg", "<Cmd>Pick grep_live<CR>", { desc = "[g]rep live", silent = true })
			vim.keymap.set(
				"n",
				"<leader>fG",
				'<Cmd>Pick grep pattern="<cword>"<CR>',
				{ desc = "[G]rep current word", silent = true }
			)
			vim.keymap.set("n", "<leader>fh", "<Cmd>Pick help<CR>", { desc = "Help tags", silent = true })
			vim.keymap.set("n", "<leader>fr", "<Cmd>Pick resume<CR>", { desc = "Resume", silent = true })

			-- Extra pickers
			local MiniExtra = require("mini.extra")
			MiniExtra.setup()

			vim.keymap.set(
				"n",
				"<leader>lr",
				"<Cmd>Pick lsp scope='references'<CR>",
				{ desc = "LSP: [r]eferences", silent = true }
			) -- grr still works with quickfix list

			vim.keymap.set(
				"n",
				"<leader>fs",
				"<Cmd>lua MiniExtra.pickers.git_files({ scope = 'modified' })<CR>",
				{ desc = "[s]tatus picker" }
			)

			vim.keymap.set("n", "<leader>fr", "<Cmd>Pick registers<CR>", { desc = "Pick [r]egisters" })

			-- Icons
			require("mini.icons").setup()

			-- Highlight patterns
			local hipatterns = require("mini.hipatterns")
			local hi_words = MiniExtra.gen_highlighter.words
			hipatterns.setup({
				highlighters = {
					-- Highlight a fixed set of common words. Will be highlighted in any place,
					-- not like "only in comments".
					fixme = hi_words({ "FIXME", "Fixme", "fixme" }, "MiniHipatternsFixme"),
					hack = hi_words({ "HACK", "Hack", "hack" }, "MiniHipatternsHack"),
					todo = hi_words({ "TODO", "Todo", "todo" }, "MiniHipatternsTodo"),
					note = hi_words({ "NOTE", "Note", "note" }, "MiniHipatternsNote"),

					-- Highlight hex color string (#aabbcc) with that color as a background
					hex_color = hipatterns.gen_highlighter.hex_color(),
				},
			})

			-- Clues after stop typing
			require("mini.clue").setup({
				triggers = {
					{ mode = "n", keys = "<Leader>" },
					{ mode = "x", keys = "<Leader>" },
				},

				clues = {
					{ mode = "n", keys = "<Leader>0", desc = "[0]x0 uploader" },
					{ mode = "n", keys = "<Leader>c", desc = "[c]ode / [c]olor" },
					{ mode = "n", keys = "<Leader>d", desc = "[d]iagnostics" },
					{ mode = "n", keys = "<Leader>e", desc = "[e]xplorer" },
					{ mode = "n", keys = "<Leader>f", desc = "[f]ind" },
					{ mode = "n", keys = "<Leader>g", desc = "[g]it" },
					{ mode = "n", keys = "<Leader>b", desc = "[b]uffer" },
					{ mode = "n", keys = "<Leader>h", desc = "[h]unks operations" },
					{ mode = "n", keys = "<Leader>l", desc = "[l]sp" },
					{ mode = "n", keys = "<Leader>m", desc = "[m]ake it..." },
					{ mode = "n", keys = "<Leader>n", desc = "[n]otifications" },
					{ mode = "n", keys = "<Leader>o", desc = "[o]org mode" },
					{ mode = "n", keys = "<Leader>s", desc = "[s]earch" },
					{ mode = "n", keys = "<Leader>t", desc = "[t]oggle" },
					{ mode = "n", keys = "<Leader>tl", desc = "Toggle [l]ine number" },
					{ mode = "n", keys = "<Leader>tr", desc = "Toggle [r]elative line number" },
				},
			})

			-- Diff (c)hunk naviation and git gutter
			require("mini.diff").setup({
				view = {
					signs = {
						add = use_special_chars and "┃" or "+",
						change = use_special_chars and "┃" or "~",
						delete = "-",
					},
				},

				mappings = {
					apply = "hs",
					reset = "hr",
					textobject = "gh",
					goto_first = "[C",
					goto_prev = "[c",
					goto_next = "]c",
					goto_last = "]C",
				},
			})
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
				"<leader>P",
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
			default_file_explorer = true,
			columns = {
				"permissions",
				"size",
				"mtime",
				unpack(use_nerd_icons and { "icon" } or {}),
			},
			delete_to_trash = true,
		},
		keys = {
			{
				"<leader>ed",
				"<cmd>Oil<CR>",
				desc = "Oil on [d]ir",
			},
		},
		dependencies = { { "nvim-mini/mini.icons", opts = {} } },
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
						"xml",
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
			float = {
				transparent = true,
				solid = false,
			},
			integrations = {
				aerial = true,
				cmp = true,
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
				treesitter = true,
				treesitter_context = true,
				rainbow_delimiters = true,
			},
		},
	},
	-- }}}
	-- {{{ Kulala                          UTIL - A curl interface
	{
		"mistweaverco/kulala.nvim",
		keys = {
			{ "<leader>Ss", desc = "Send request" },
			{ "<leader>Sa", desc = "Send all requests" },
			{ "<leader>Sb", desc = "Open scratchpad" },
		},
		ft = { "http", "rest" },
		opts = {
			global_keymaps = true,
			global_keymaps_prefix = "<leader>S",
			kulala_keymaps_prefix = "",
		},
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
	-- {{{ GitLineage                      VC - History of selected lines
	--
	{
		"lionyxml/gitlineage.nvim",
		dependencies = {
			"sindrets/diffview.nvim",
		},
		config = function()
			require("gitlineage").setup({
				keymap = "<leader>gh",
				keys = { yank_commit = "y" },
			})
		end,
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
vim.opt.shortmess:append("I")
vim.cmd.colorscheme("catppuccin")
vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
vim.api.nvim_set_hl(0, "NormalNC", { bg = "none" })
-- vim.api.nvim_set_hl(0, "EndOfBuffer", { bg = "none" }) -- this makes ~ visible, I don't like it

-- For the times I came across no selectors or UI's let me drop this here...
--
-- vim.ui.select = function(items, opts, on_choice)
-- 	local fmt = opts.format_item or tostring
-- 	local lines = {}
-- 	for i, item in ipairs(items) do
-- 		lines[i] = fmt(item)
-- 	end
--
-- 	local buf = vim.api.nvim_create_buf(false, true)
-- 	vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
-- 	vim.bo[buf].modifiable = false
--
-- 	local content_width = math.max(unpack(vim.tbl_map(function(l)
-- 		return #l
-- 	end, lines)))
-- 	if opts.prompt then
-- 		content_width = math.max(content_width, #opts.prompt)
-- 	end
-- 	local width = math.max(50, content_width + 2)
--
-- 	local editor_w = vim.o.columns
-- 	local editor_h = vim.o.lines
-- 	local height = #lines
--
-- 	local win = vim.api.nvim_open_win(buf, true, {
-- 		relative = "editor",
-- 		row = math.floor((editor_h - height) / 2),
-- 		col = math.floor((editor_w - width) / 2),
-- 		width = width,
-- 		height = height,
-- 		style = "minimal",
-- 		border = "rounded",
-- 		title = opts.prompt or "Select",
-- 	})
--
-- 	local function close(idx)
-- 		vim.api.nvim_win_close(win, true)
-- 		vim.api.nvim_buf_delete(buf, { force = true })
-- 		if idx then
-- 			on_choice(items[idx], idx)
-- 		else
-- 			on_choice(nil)
-- 		end
-- 	end
--
-- 	vim.keymap.set("n", "<CR>", function()
-- 		local cursor = vim.api.nvim_win_get_cursor(win)
-- 		close(cursor[1])
-- 	end, { buffer = buf })
--
-- 	vim.keymap.set("n", "<Esc>", function()
-- 		close(nil)
-- 	end, { buffer = buf })
-- 	vim.keymap.set("n", "q", function()
-- 		close(nil)
-- 	end, { buffer = buf })
-- end
--
-- vim.ui.input = function(opts, on_confirm)
-- 	local default = opts.default or ""
--
-- 	local buf = vim.api.nvim_create_buf(false, true)
-- 	vim.api.nvim_buf_set_lines(buf, 0, -1, false, { default })
--
-- 	local width = math.max(100, #default + 2)
-- 	local editor_w = vim.o.columns
-- 	local editor_h = vim.o.lines
--
-- 	local win = vim.api.nvim_open_win(buf, true, {
-- 		relative = "editor",
-- 		row = math.floor(editor_h / 2),
-- 		col = math.floor((editor_w - width) / 2),
-- 		width = width,
-- 		height = 1,
-- 		style = "minimal",
-- 		border = "rounded",
-- 		title = opts.prompt or "Input",
-- 	})
--
-- 	vim.cmd("startinsert!")
--
-- 	local function close(value)
-- 		vim.cmd("stopinsert")
-- 		vim.api.nvim_win_close(win, true)
-- 		vim.api.nvim_buf_delete(buf, { force = true })
-- 		on_confirm(value)
-- 	end
--
-- 	vim.keymap.set("i", "<CR>", function()
-- 		local text = vim.api.nvim_buf_get_lines(buf, 0, 1, false)[1]
-- 		close(text)
-- 	end, { buffer = buf })
--
-- 	vim.keymap.set({ "i", "n" }, "<Esc>", function()
-- 		close(nil)
-- 	end, { buffer = buf })
-- end

-- New Extui for :messages :reg :marks
local ok, extui = pcall(require, "vim._extui")
if ok then
	extui.enable({
		enable = true,
	})
end

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
vim.opt.spelllang = { "en_us", "pt_br" }
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

vim.keymap.set("n", "n", "nzzzv", { desc = "Next search result (centered)" })
vim.keymap.set("n", "N", "Nzzzv", { desc = "Previous search result (centered)" })

vim.keymap.set({ "n", "v" }, "<C-d>", "<C-d>zz", { silent = true })
vim.keymap.set({ "n", "v" }, "<C-u>", "<C-u>zz", { silent = true })

vim.keymap.set(
	"x",
	"<leader>p",
	'"_dP',
	{ noremap = true, silent = true },
	{ desc = "Paste without loosing yanked data" }
)

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

-- Diagnostics --
vim.keymap.set("n", "[d", function()
	vim.diagnostic.jump({ count = -1, float = true })
end, { desc = "Go to previous diagnostic message" })

vim.keymap.set("n", "]d", function()
	vim.diagnostic.jump({ count = 1, float = true })
end, { desc = "Go to next diagnostic message" })

vim.keymap.set("n", "<leader>do", vim.diagnostic.open_float, { desc = "[o]pen float diagnostic" })

vim.keymap.set("n", "<leader>dl", function()
	vim.diagnostic.setloclist()
	vim.cmd.wincmd("p")
end, { desc = "Feed [d]iagnostics to [l]oclist" })

vim.keymap.set("n", "<leader>dq", function()
	vim.diagnostic.setqflist()
	vim.cmd.wincmd("p")
end, { desc = "Feed [d]iagnostics to [q]uickfix" })

vim.keymap.set("n", "<leader>ti", function()
	local virtual_text = vim.diagnostic.config().virtual_text
	vim.diagnostic.config({ virtual_text = not virtual_text })
end, { desc = "Toggle [i]nline diagnostics" })

vim.keymap.set("n", "<leader>td", function()
	vim.diagnostic.enable(not vim.diagnostic.is_enabled())
end, { desc = "Toggle [d]iagnostics" })

vim.diagnostic.config({
	float = { border = vim.o.winborder },
	signs = {
		text = {
			[vim.diagnostic.severity.ERROR] = custom_diagnostic_symbols.error,
			[vim.diagnostic.severity.WARN] = custom_diagnostic_symbols.warn,
			[vim.diagnostic.severity.HINT] = custom_diagnostic_symbols.hint,
			[vim.diagnostic.severity.INFO] = custom_diagnostic_symbols.info,
		},
	},
})

-- Some other toggles --
vim.keymap.set("n", "<leader>ta", "<cmd>AerialToggle!<CR>", { desc = "Toggle [a]erial" })
vim.keymap.set("n", "<leader>tc", "<cmd>TSContextToggle<CR>", { desc = "Toggle treesitter [c]ontext" })
vim.keymap.set("n", "<leader>tI", "<cmd>IndentationLineToggle<CR>", { desc = "Toggle [I]ndent line" })

-- Buffers --

vim.keymap.set("n", "<leader>gS", function()
	local output = vim.fn.systemlist("git status --porcelain")
	if vim.v.shell_error ~= 0 then
		vim.notify("Not a git repository", vim.log.levels.ERROR)
		return
	end
	if #output == 0 then
		vim.notify("No changed files", vim.log.levels.INFO)
		return
	end
	local items = {}
	for _, line in ipairs(output) do
		local status = line:sub(1, 2)
		local file = line:sub(4)
		table.insert(items, { status = status, file = file })
	end
	vim.ui.select(items, {
		prompt = "Git Status: ",
		format_item = function(item)
			return item.status .. " " .. item.file
		end,
	}, function(choice)
		if choice then
			vim.cmd.edit(choice.file)
		end
	end)
end, { desc = "[g]it [s]tatus picker" })

vim.keymap.set("n", "<leader>bb", function()
	local bufs = vim.fn.getbufinfo({ buflisted = 1 })
	local items = {}
	for _, buf in ipairs(bufs) do
		local name = buf.name ~= "" and vim.fn.fnamemodify(buf.name, ":~:.") or "[No Name]"
		table.insert(items, { bufnr = buf.bufnr, name = name })
	end
	vim.ui.select(items, {
		prompt = "Buffer: ",
		format_item = function(item)
			return item.name
		end,
	}, function(choice)
		if choice then
			vim.api.nvim_set_current_buf(choice.bufnr)
		end
	end)
end, { desc = "[b]uffer picker" })

vim.keymap.set("n", "<leader>bd", ":bd<CR>", { desc = "buffer [d]elete", silent = true })
vim.keymap.set("n", "<leader>bD", ":bufdo bd<CR>", { desc = "buffer [D]elete all", silent = true })

vim.keymap.set({ "n", "v" }, "<leader>L", ":Lazy<CR>", { desc = "[L]azy", silent = true })
vim.keymap.set({ "n", "v" }, "<leader>M", ":Mason<CR>", { desc = "[M]ason", silent = true })
vim.keymap.set({ "n", "v" }, "<leader>S", ":Mason<CR>", { desc = "[S]end Requests", silent = true })

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

-- }}}

-- {{{ MY - GIT ANNOTATE
vim.keymap.set("n", "<leader>ga", function()
	local file = vim.fn.expand("%")
	if file == "" then
		vim.notify("No file name for current buffer", vim.log.levels.WARN)
		return
	end

	local cursor_line = vim.fn.line(".")
	local original_win = vim.api.nvim_get_current_win()

	local buf = vim.api.nvim_create_buf(false, true)

	local annotate = vim.fn.systemlist({ "git", "annotate", file })
	if vim.v.shell_error ~= 0 then
		vim.notify("git annotate failed or repo not found", vim.log.levels.WARN)
		return
	end

	vim.api.nvim_buf_set_lines(buf, 0, -1, false, annotate)
	vim.api.nvim_buf_call(buf, function()
		vim.cmd([[
              syntax match GitAnnotateHash /^\x\+/
              syntax match GitAnnotateAuthor /(\zs[^)]*\d\{4\}-\d\{2\}-\d\{2\}/
              syntax match GitAnnotateLineNr /\d\+)$/

              highlight default link GitAnnotateHash Identifier
              highlight default link GitAnnotateAuthor String
              highlight default link GitAnnotateLineNr LineNr
          ]])
	end)

	vim.bo[buf].modifiable = false
	vim.bo[buf].buflisted = false

	vim.cmd("topleft vsplit")
	vim.api.nvim_win_set_buf(0, buf)

	-- jump to same line in the annotate buffer
	local line_count = vim.api.nvim_buf_line_count(buf)
	local target = math.min(cursor_line, line_count)
	vim.api.nvim_win_set_cursor(0, { target, 0 })

	-- enable scrollbind on both windows so they stay in sync
	vim.wo.scrollbind = true
	vim.api.nvim_win_set_option(original_win, "scrollbind", true)
	vim.cmd("syncbind")
end, { desc = "Git annotate current file" })
-- }}}
-- {{{ MY - TABLINE
vim.keymap.set("n", "<leader>tn", ":tabnew<CR>", { desc = "Toggle [t]abs" })
vim.keymap.set("n", "<leader>tx", ":tabclose<CR>", { desc = "[T]ab E[x]terminate" })

vim.keymap.set("n", "<leader>tt", function()
	if vim.o.showtabline == 2 then
		vim.o.showtabline = 0
	else
		vim.o.showtabline = 2
	end
end, { desc = "Toggle [t]abs" })

vim.keymap.set("n", "]t", ":tabnext<CR>", { desc = "Next tab", silent = true })
vim.keymap.set("n", "[t", ":tabprevious<CR>", { desc = "Previous tab", silent = true })

vim.api.nvim_set_hl(0, "TabLine", { bg = "NONE", fg = "#666666" }) -- fallback for non-pill content
vim.api.nvim_set_hl(0, "TabLineFill", { bg = "NONE" }) --             background of unused space

vim.api.nvim_set_hl(0, "TabLinePillActiveLeft", { fg = "#8aadf4", bg = "#1e1e2e" })
vim.api.nvim_set_hl(0, "TabLinePillActiveText", { fg = "#1e1e2e", bg = "#8aadf4", bold = false })
vim.api.nvim_set_hl(0, "TabLinePillActiveRight", { fg = "#8aadf4", bg = "#1e1e2e" })

vim.api.nvim_set_hl(0, "TabLinePillInactiveLeft", { fg = "#737994", bg = "#1e1e2e" })
vim.api.nvim_set_hl(0, "TabLinePillInactiveText", { fg = "#1e1e2e", bg = "#737994" })
vim.api.nvim_set_hl(0, "TabLinePillInactiveRight", { fg = "#737994", bg = "#1e1e2e" })

vim.o.tabline = "%!v:lua.PillTabline()"

function _G.PillTabline()
	local s = ""
	local tabs = vim.api.nvim_list_tabpages()
	local current = vim.api.nvim_get_current_tabpage()

	for i, tab in ipairs(tabs) do
		local is_active = (tab == current)

		local hl_left = is_active and "%#TabLinePillActiveLeft#" or "%#TabLinePillInactiveLeft#"
		local hl_text = is_active and "%#TabLinePillActiveText#" or "%#TabLinePillInactiveText#"
		local hl_right = is_active and "%#TabLinePillActiveRight#" or "%#TabLinePillInactiveRight#"

		s = s .. hl_left .. ""
		s = s .. hl_text .. " " .. i .. " "
		s = s .. hl_right .. ""
		s = s .. "%#TabLine# " -- reset highlight after each tab
	end

	return s
end
--- }}}
-- {{{ MY - GPG
local function get_recipient_from_file(filepath)
	local handle = io.popen("gpg --list-packets " .. vim.fn.shellescape(filepath) .. " 2>&1")
	if not handle then
		return nil
	end
	local result = handle:read("*a")
	handle:close()
	local key_id = result:match("keyid (%S+)")
	return key_id
end

local gpgGroup = vim.api.nvim_create_augroup("customGpg", { clear = true })

vim.api.nvim_create_autocmd({ "BufReadPre", "FileReadPre" }, {
	pattern = "*.gpg",
	group = gpgGroup,
	callback = function()
		-- Make sure nothing is written to shada file while editing an encrypted file.
		vim.opt_local.shada = nil
		-- We don't want a swap file, as it writes unencrypted data to disk
		vim.opt_local.swapfile = false
		-- Switch to binary mode to read the encrypted file
		vim.opt_local.bin = true

		-- Save the current 'ch' value to a buffer-local variable
		vim.b.ch_save = vim.o.ch
		vim.o.ch = 2
	end,
})

vim.api.nvim_create_autocmd({ "BufReadPost", "FileReadPost" }, {
	pattern = "*.gpg",
	group = gpgGroup,
	callback = function()
		-- Only decrypt if the file exists on disk. New files won't be decrypted.
		if vim.fn.filereadable(vim.fn.expand("%")) == 1 then
			vim.b.gpg_recipient = get_recipient_from_file(vim.fn.expand("%"))
			vim.cmd("silent! '%!gpg --decrypt --quiet --yes --no-use-agent'")
		end

		-- Switch to normal mode for editing
		vim.opt_local.bin = false

		-- Restore the 'ch' value from the buffer-local variable
		if vim.b.ch_save then
			vim.o.ch = vim.b.ch_save
			vim.b.ch_save = nil
		end
		vim.api.nvim_exec_autocmds("BufReadPost", { pattern = vim.fn.expand("%:r") })
	end,
})

local function get_gpg_keys()
	local handle = io.popen("gpg --list-secret-keys --with-colons")
	if not handle then
		return {}
	end
	local result = handle:read("*a")
	handle:close()

	local keys = {}
	local current_key_id = nil

	for line in result:gmatch("([^\n]+)") do
		local fields = {}
		for field in line:gmatch("([^:]+)") do
			table.insert(fields, field)
		end

		if fields[1] == "sec" then
			current_key_id = fields[5]
		elseif fields[1] == "uid" and current_key_id and fields[10] then
			table.insert(keys, { key_id = current_key_id, user_id = fields[10] })
		end
	end
	return keys
end

local function select_recipient_sync()
	local keys = get_gpg_keys()
	if #keys == 0 then
		vim.notify("No GPG keys found.", vim.log.levels.WARN)
		return vim.fn.input("Enter GPG recipient: ")
	end

	local display_options = {}
	for i, key in ipairs(keys) do
		table.insert(display_options, string.format("%d. %s (%s)", i, key.user_id, key.key_id))
	end
	table.insert(display_options, string.format("%d. Enter recipient manually", #keys + 1))

	vim.api.nvim_echo({ { "Select GPG recipient:" } }, true, {})
	for _, option in ipairs(display_options) do
		vim.api.nvim_echo({ { option } }, true, {})
	end

	local choice_str = vim.fn.input("Enter choice: ")
	local choice_idx = tonumber(choice_str)

	if choice_idx then
		if keys[choice_idx] then
			return keys[choice_idx].key_id
		elseif choice_idx == #keys + 1 then
			return vim.fn.input("Enter GPG recipient (e.g., email or key ID): ")
		end
	end

	return nil
end

-- Convert all text to encrypted text before writing
vim.api.nvim_create_autocmd({ "BufWritePre", "FileWritePre" }, {
	pattern = "*.gpg",
	group = gpgGroup,
	callback = function()
		if not vim.b.gpg_recipient then
			vim.b.gpg_recipient = select_recipient_sync()
		end

		if vim.b.gpg_recipient and vim.b.gpg_recipient ~= "" then
			local cmd = "'[,']!gpg --quiet --yes --no-use-agent -ae -r " .. vim.b.gpg_recipient
			vim.cmd(cmd)
		else
			vim.notify("GPG encryption cancelled: No recipient selected.", vim.log.levels.WARN)
			-- Prevent writing the file if no recipient is selected
			error("GPG encryption cancelled.")
		end
	end,
})

-- Undo the encryption so we are back in the normal text, directly
-- after the file has been written.
vim.api.nvim_create_autocmd({ "BufWritePost", "FileWritePost" }, {
	pattern = "*.gpg",
	group = gpgGroup,
	command = "u",
})
--}}}

-- vim: ts=2 sts=2 sw=2 et fileencoding=utf-8:foldmethod=marker
