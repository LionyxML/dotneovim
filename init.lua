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

					map("gd", require("telescope.builtin").lsp_definitions, "[G]oto [D]efinition")

					map("gr", require("telescope.builtin").lsp_references, "[G]oto [R]eferences")

					map("gI", require("telescope.builtin").lsp_implementations, "[G]oto [I]mplementation")

					map("<leader>D", require("telescope.builtin").lsp_type_definitions, "Type [D]efinition")

					map("<leader>ds", require("telescope.builtin").lsp_document_symbols, "[D]ocument [S]ymbols")

					map(
						"<leader>ws",
						require("telescope.builtin").lsp_dynamic_workspace_symbols,
						"[W]orkspace [S]ymbols"
					)

					map("<leader>rn", vim.lsp.buf.rename, "[R]e[n]ame")

					map("<leader>ca", vim.lsp.buf.code_action, "[C]ode [A]ction")

					map("<leader>co", function()
						vim.lsp.buf.code_action({ context = { only = { "source.organizeImports" } }, apply = true })
					end, "[C]ode [O]rganize imports")

					map("K", vim.lsp.buf.hover, "Hover Documentation")

					map("gD", vim.lsp.buf.declaration, "[G]oto [D]eclaration")

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
						end, "[T]oggle Inlay [H]ints")
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
					},
				},
			}

			require("mason").setup({
				ui = {
					border = "rounded",
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
	-- {{{ Nvim-DAP                        DAP - The Debugger Adapter Protocol and Controls
	{
		"mfussenegger/nvim-dap",
		event = "VeryLazy",
		opts = {},
		config = function()
			vim.keymap.set("n", "<leader>dc", require("dap").continue, { desc = "DAP - [C]ontinue" })
			vim.keymap.set("n", "<leader>dO", require("dap").step_over, { desc = "DAP - Step [O]ver" })
			vim.keymap.set("n", "<leader>di", require("dap").step_into, { desc = "DAP - Setp [I]nto" })
			vim.keymap.set("n", "<leader>do", require("dap").step_out, { desc = "DAP - Step [o]ut" })
			vim.keymap.set("n", "<leader>db", require("dap").toggle_breakpoint, { desc = "DAP - Toggle [b]reakpoint" })
			vim.keymap.set("n", "<leader>dB", function()
				require("dap").set_breakpoint(vim.fn.input("Breakpoint condition: "))
			end, { desc = "DAP - [B]reakpoint condition" })

			local js_based_languages = { "typescript", "javascript", "typescriptreact" }

			for _, language in ipairs(js_based_languages) do
				require("dap").configurations[language] = {
					{
						type = "pwa-node",
						request = "launch",
						name = "Launch file",
						program = "${file}",
						cwd = "${workspaceFolder}",
					},
					{
						type = "pwa-node",
						request = "attach",
						name = "Attach",
						processId = require("dap.utils").pick_process,
						cwd = "${workspaceFolder}",
					},
					{
						type = "pwa-chrome",
						request = "launch",
						name = 'Start Chrome with "localhost"',
						url = "http://localhost:3000",
						webRoot = "${workspaceFolder}",
						userDataDir = "${workspaceFolder}/.vscode/vscode-chrome-debug-userdatadir",
					},
				}
			end
		end,
	},
	-- }}}
	-- {{{ VSCODE-JS-Debug                 DAP - The debug from vscode!
	-- Just uncomment when debug is needed. This is noisy with Lazy Update
	-- {
	--  "microsoft/vscode-js-debug",
	--  -- NOTE: This is a huge build, it needs Chromium :(
	--  -- If this build fails or timeout, might need to go in
	--  -- ~/.local/share/nvim/lazy/vscode-js-debug and run:
	--  build = "npm install --legacy-peer-deps && npx gulp vsDebugServerBundle && mv dist out",
	-- },
	-- }}}
	-- {{{ Nvim-DAP-VSCode-JS              DAP - What makes the VSCODE-JS-Debug work with neovim DAP!
	{
		"mxsdev/nvim-dap-vscode-js",
		event = "VeryLazy",
		config = function()
			---@diagnostic disable-next-line: missing-fields
			require("dap-vscode-js").setup({
				-- node_path = "node", -- Path of node executable. Defaults to $NODE_PATH, and then "node"
				-- debugger_path = "(runtimedir)/site/pack/packer/opt/vscode-js-debug", -- Path to vscode-js-debug installation.
				debugger_path = vim.fn.stdpath("data") .. "/lazy/vscode-js-debug",
				-- debugger_cmd = { "extension" }, -- Command to use to launch the debug server. Takes precedence over `node_path` and `debugger_path`.
				adapters = {
					"chrome",
					"pwa-node",
					"pwa-chrome",
					"pwa-msedge",
					"node-terminal",
					"pwa-extensionHost",
					"node",
					"chrome",
				}, -- which adapters to register in nvim-dap
				-- log_file_path = "(stdpath cache)/dap_vscode_js.log" -- Path for file logging
				-- log_file_level = false -- Logging level for output to file. Set to false to disable file logging.
				-- log_console_level = vim.log.levels.ERROR -- Logging level for output to console. Set to false to disable console output.
			})
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
			end, { desc = "Format file or range (in visual mode)" })

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
				function()
					require("telescope").extensions.yank_history.yank_history({})
				end,
				desc = "Open Yank History",
			},
			--setSelectedTimePeriod FIXME: do we need all of this or only leader p ?
			-- {
			-- 	"y",
			-- 	"<Plug>(YankyYank)",
			-- 	mode = { "n", "x" },
			-- 	desc = "Yank text",
			-- },
			-- {
			-- 	"p",
			-- 	"<Plug>(YankyPutAfter)",
			-- 	mode = { "n", "x" },
			-- 	desc = "Put yanked text after cursor",
			-- },
			-- {
			-- 	"P",
			-- 	"<Plug>(YankyPutBefore)",
			-- 	mode = { "n", "x" },
			-- 	desc = "Put yanked text before cursor",
			-- },
			-- {
			-- 	"gp",
			-- 	"<Plug>(YankyGPutAfter)",
			-- 	mode = { "n", "x" },
			-- 	desc = "Put yanked text after selection",
			-- },
			-- {
			-- 	"gP",
			-- 	"<Plug>(YankyGPutBefore)",
			-- 	mode = { "n", "x" },
			-- 	desc = "Put yanked text before selection",
			-- },
			-- {
			-- 	"]p",
			-- 	"<Plug>(YankyPutIndentAfterLinewise)",
			-- 	desc = "Put indented after cursor (linewise)",
			-- },
			-- {
			-- 	"[p",
			-- 	"<Plug>(YankyPutIndentBeforeLinewise)",
			-- 	desc = "Put indented before cursor (linewise)",
			-- },
			-- {
			-- 	"]P",
			-- 	"<Plug>(YankyPutIndentAfterLinewise)",
			-- 	desc = "Put indented after cursor (linewise)",
			-- },
			-- {
			-- 	"[P",
			-- 	"<Plug>(YankyPutIndentBeforeLinewise)",
			-- 	desc = "Put indented before cursor (linewise)",
			-- },
			-- {
			-- 	">p",
			-- 	"<Plug>(YankyPutIndentAfterShiftRight)",
			-- 	desc = "Put and indent right",
			-- },
			-- {
			-- 	"<p",
			-- 	"<Plug>(YankyPutIndentAfterShiftLeft)",
			-- 	desc = "Put and indent left",
			-- },
			-- {
			-- 	">P",
			-- 	"<Plug>(YankyPutIndentBeforeShiftRight)",
			-- 	desc = "Put before and indent right",
			-- },
			-- {
			-- 	"<P",
			-- 	"<Plug>(YankyPutIndentBeforeShiftLeft)",
			-- 	desc = "Put before and indent left",
			-- },
			-- {
			-- 	"=p",
			-- 	"<Plug>(YankyPutAfterFilter)",
			-- 	desc = "Put after applying a filter",
			-- },
			-- {
			-- 	"=P",
			-- 	"<Plug>(YankyPutBeforeFilter)",
			-- 	desc = "Put before applying a filter",
			-- },
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
			end)
		end,
	},
	-- }}}
	-- {{{ IconPicker                      EDIT - Icons picker (utf, nerdfonts, alt font, symbols...)
	{
		"ziontee113/icon-picker.nvim",
		event = "VeryLazy",
		config = function()
			require("icon-picker").setup({ disable_legacy_commands = true })

			local opts = { noremap = true, silent = true }

			vim.keymap.set("n", "<Leader>ii", "<cmd>IconPickerNormal<cr>", opts)
			vim.keymap.set("n", "<Leader>iy", "<cmd>IconPickerYank<cr>", opts) --> Yank the selected icon into register
			vim.keymap.set("i", "<C-i>", "<cmd>IconPickerInsert<cr>", opts)
		end,
	},
	-- }}}
	-- {{{ Codeium                         EDIT - Copilot like alternative
	{
		"Exafunction/codeium.nvim",
		event = "VeryLazy",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"hrsh7th/nvim-cmp",
		},
		config = function()
			require("codeium").setup({})

			local Source = require("codeium.source")

			local function is_codeium_enabled()
				local enabled = vim.b["codeium_enabled"]
				if enabled == nil then
					enabled = vim.g["codeium_enabled"]
					if enabled == nil then
						enabled = true -- enable by default
					end
				end
				return enabled
			end

			---@diagnostic disable-next-line: duplicate-set-field
			function Source:is_available()
				local enabled = is_codeium_enabled()
				---@diagnostic disable-next-line: undefined-field
				return enabled and self.server.is_healthy()
			end

			vim.api.nvim_set_keymap("n", "<leader>tC", "", {
				desc = "[C]odium Toggle",
				callback = function()
					local new_enabled = not is_codeium_enabled()
					vim.b["codeium_enabled"] = new_enabled
					if new_enabled then
						vim.notify("Codeium enabled in buffer")
					else
						vim.notify("Codeium disabled in buffer")
					end
				end,
				noremap = true,
			})

			vim.api.nvim_set_keymap("n", "<leader>tC", "", {
				desc = "[C]odium Toggle",
				callback = function()
					local new_enabled = not is_codeium_enabled()
					vim.b["codeium_enabled"] = new_enabled
					if new_enabled then
						vim.notify("Codeium enabled in buffer")
					else
						vim.notify("Codeium disabled in buffer")
					end
				end,
				noremap = true,
			})
		end,
	},
	-- }}}
	-- {{{ Vim-Dadbod                      DB - multi db client
	{
		"tpope/vim-dadbod",
		event = "VeryLazy",
	},
	-- }}}
	-- {{{ Vim-Dadbod-completion           DB - dadbod completion
	{
		"kristijanhusak/vim-dadbod-completion",
		event = "VeryLazy",
	},
	-- }}}
	-- {{{ Vim-Dadbod-ui                   DB - dadbod better ui
	{
		"kristijanhusak/vim-dadbod-ui",
		event = "VeryLazy",
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
				desc = "Open Oil File Manager",
			},
		},
		-- Optional dependencies
		-- dependencies = { "echasnovski/mini.icons" },
		dependencies = { "nvim-tree/nvim-web-devicons" }, -- use if prefer nvim-web-devicons
	},
	-- }}}
	-- {{{ Nvim-Tree                       FILE - The side window tree explorer
	{
		-- Tree explorer
		"nvim-tree/nvim-tree.lua",
		event = "VeryLazy",
		dependencies = {
			"nvim-tree/nvim-web-devicons",
		},

		config = function()
			vim.keymap.set("n", "<leader>ee", "<cmd>NvimTreeToggle<CR>", { desc = "Toggle file explorer" })
			vim.keymap.set(
				"n",
				"<leader>ef",
				"<cmd>NvimTreeFindFileToggle<CR>",
				{ desc = "Toggle file explorer on current file" }
			)
			vim.keymap.set("n", "<leader>ec", "<cmd>NvimTreeCollapse<CR>", { desc = "Collapse file explorer" })
			vim.keymap.set("n", "<leader>er", "<cmd>NvimTreeRefresh<CR>", { desc = "Refresh file explorer" })

			require("nvim-tree").setup({
				sort_by = "case_sensitive",
				view = {
					width = 30,
				},
				filters = {
					dotfiles = false,
				},
				git = {
					enable = true,
					ignore = false,
					timeout = 500,
				},

				renderer = {
					indent_markers = {
						enable = true,
					},
					group_empty = true,
					highlight_git = false,
					root_folder_label = ":t",
					icons = {
						git_placement = "signcolumn",
						glyphs = {
							default = "",
							symlink = "",
							folder = {
								arrow_open = "",
								arrow_closed = "",
								default = "",
								open = "",
								empty = "",
								empty_open = "",
								symlink = "",
								symlink_open = "",
							},
							git = {
								unstaged = "",
								staged = "S",
								unmerged = "",
								renamed = "➜",
								untracked = "U",
								deleted = "",
								ignored = "◌",
							},
						},
					},
				},
				diagnostics = {
					enable = true,
					show_on_dirs = true,
					icons = {
						hint = "󰌶",
						info = "",
						warning = "󰀪",
						error = "󰅚",
					},
				},
			})
		end,
	},
	-- }}}
	-- {{{ Telescope                       FIND - The cool finder/visualizer with previews
	{
		-- Fuzzy Finder (files, lsp, etc)
		"nvim-telescope/telescope.nvim",
		config = function()
			local tscope = require("telescope")
			local tscopebi = require("telescope.builtin")
			local tscopeth = require("telescope.themes")
			local tscopeso = require("telescope.sorters")

			tscope.setup({
				extensions = {
					undo = {},
					["ui-select"] = {
						require("telescope.themes").get_dropdown({}),
					},
				},
				defaults = {
					mappings = {
						i = {
							["<C-u>"] = false,
							["<C-d>"] = "delete_buffer",
						},
					},
				},
			})

			-- Telescope UI-Select (handles vim.ui.)
			tscope.load_extension("ui-select")

			-- Use Telescope Undo
			tscope.load_extension("undo")
			vim.keymap.set("n", "<leader>U", "<cmd>Telescope undo<cr>")

			-- Enable telescope fzf native, if installed
			pcall(tscope.load_extension, "fzf")

			vim.keymap.set("n", "<leader>?", tscopebi.oldfiles, { desc = "[?] Find recently opened files" })
			vim.keymap.set("n", "<leader><space>", tscopebi.buffers, { desc = "[ ] Find existing buffers" })
			vim.keymap.set("n", "<leader>bl", tscopebi.buffers, { desc = "Buffer [l]ist" })
			vim.keymap.set("n", "<leader>bq", tscopebi.quickfix, { desc = "Buffer [q]uickfix" })
			vim.keymap.set("n", "<leader>/", function()
				tscopebi.current_buffer_fuzzy_find(tscopeth.get_dropdown({
					winblend = 0,
					previewer = true,
					sorter = tscopeso.get_substr_matcher(),
				}))
			end, { desc = "[/] Fuzzily search in current buffer" })

			vim.keymap.set("n", "<leader>gf", tscopebi.git_files, { desc = "Search [G]it [F]iles" })
			vim.keymap.set("n", "<leader>gc", tscopebi.git_branches, { desc = "[c]heckout Branch" })
			vim.keymap.set("n", "<leader>gs", tscopebi.git_status, { desc = "[S]tatus" })
			vim.keymap.set("n", "<leader>gC", tscopebi.git_commits, { desc = "[C]ommits" })
			vim.keymap.set("n", "<leader>sf", tscopebi.find_files, { desc = "[s]earch [f]iles" })
			vim.keymap.set("n", "<leader>sh", tscopebi.help_tags, { desc = "[s]earch [h]elp" })
			vim.keymap.set("n", "<leader>sw", tscopebi.grep_string, { desc = "[s]earch current [w]ord" })
			vim.keymap.set("n", "<leader>sg", tscopebi.live_grep, { desc = "[s]earch by [g]rep" })
			vim.keymap.set("n", "<leader>sd", tscopebi.diagnostics, { desc = "[s]earch [d]iagnostics" })
			vim.keymap.set("n", "<leader>sr", tscopebi.resume, { desc = "[s]earch [r]esume" })
		end,
		branch = "0.1.x",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"debugloop/telescope-undo.nvim",
			"nvim-telescope/telescope-ui-select.nvim",
			-- Fuzzy Finder Algorithm which requires local dependencies to be built.
			-- Only load if `make` is available. Make sure you have the system
			-- requirements installed.
			{
				"nvim-telescope/telescope-fzf-native.nvim",
				-- NOTE: If you are having trouble with this installation,
				--       refer to the README for telescope-fzf-native for more instructions.
				build = "make",
				cond = function()
					return vim.fn.executable("make") == 1
				end,
			},
		},
	},
	-- }}}
	-- {{{ Remote.Nvim                     REMOTE - Allows remote development
	{
		"amitds1997/remote-nvim.nvim",
		event = "VeryLazy",
		version = "*", -- Pin to GitHub releases
		dependencies = {
			"nvim-lua/plenary.nvim", -- For standard functions
			"MunifTanjim/nui.nvim", -- To build the plugin UI
			"nvim-telescope/telescope.nvim", -- For picking b/w different remote methods
		},
		config = true,
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
				cloak_telescope = true,
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
						swap = {
							enable = true,
							swap_next = {
								["<leader>a"] = "@parameter.inner",
							},
							swap_previous = {
								["<leader>A"] = "@parameter.inner",
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
	-- {{{ HL-Chunk                        TXT - Provides chunk/indent line + cdolores linum
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
	-- {{{ Colorizer                       TXT - Colorize color codes
	{
		"norcalli/nvim-colorizer.lua",
		config = function()
			require("colorizer").setup()
		end,
	},
	-- }}}
	-- {{{ Dashboard-Nvim                  UI - Initial dashboard screen
	{
		"glepnir/dashboard-nvim",
		event = "VimEnter",
		config = function()
			local logo = [[

"                                                                   "
"      ████ ██████           █████      ██                    "
"     ███████████             █████                            "
"     █████████ ███████████████████ ███   ███████████  "
"    █████████  ███    █████████████ █████ ██████████████  "
"   █████████ ██████████ █████████ █████ █████ ████ █████  "
" ███████████ ███    ███ █████████ █████ █████ ████ █████ "
"██████  █████████████████████ ████ █████ █████ ████ ██████"

  ]]
			logo = string.rep("\n", 8) .. string.gsub(logo, '"', "") .. "\n\n"

			require("dashboard").setup({
				theme = "doom",
				config = {
					header = vim.split(logo, "\n"),
					center = { { action = "", desc = "", icon = " " } },
					footer = function()
						local stats = require("lazy").stats()
						local ms = (math.floor(stats.startuptime * 100 + 0.5) / 100)
						return {
							"Loaded " .. stats.loaded .. "/" .. stats.count .. " plugins in " .. ms .. "ms",
						}
					end,
				},
			})
		end,
		dependencies = { { "nvim-tree/nvim-web-devicons" } },
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
				theme = "catppuccin",
				-- theme = "palenight",
				-- theme = "nightfly",
				component_separators = "",
				-- component_separators = { left = '', right = '' },
				section_separators = { left = "", right = "" },
				-- section_separators = { right = "" },
			},
			sections = {
				lualine_a = { "mode" },
				lualine_b = {
					{
						"branch",
						fmt = function(branch)
							local limit = 20
							return branch:sub(1, limit) .. (branch:len() > limit and "…" or "")
						end,
					},
					"diff",
					"diagnostics",
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
				lualine_z = { "location" },
			},
		},
	},
	-- }}}
	-- {{{ Nvim-DAP-UI                     UI - Beautiful DAP UI!
	{
		"rcarriga/nvim-dap-ui",
		event = "VeryLazy",
		config = function()
			require("dapui").setup()

			local dap, dapui = require("dap"), require("dapui")

			dap.listeners.after.event_initialized["dapui_config"] = function()
				dapui.open({})
			end
			dap.listeners.before.event_terminated["dapui_config"] = function()
				dapui.close({})
			end
			dap.listeners.before.event_exited["dapui_config"] = function()
				dapui.close({})
			end

			vim.keymap.set("n", "<leader>tD", require("dapui").toggle)
		end,
		dependencies = { "mfussenegger/nvim-dap", "nvim-neotest/nvim-nio" },
	},
	-- }}}
	-- {{{ Noice                           UI - THE Beautiful UI for Neovim
	{
		"folke/noice.nvim",
		event = "VeryLazy",
		opts = {
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
				bottom_search = false, -- use a classic bottom cmdline for search
				command_palette = true, -- position the cmdline and popupmenu together
				long_message_to_split = true, -- long messages will be sent to a split
				inc_rename = true, -- enables an input dialog for inc-rename.nvim
				lsp_doc_border = true, -- add a border to hover docs and signature help
			},
		},
		keys = {
			{
				"<S-Enter>",
				function()
					require("noice").redirect(vim.fn.getcmdline())
				end,
				mode = "c",
				desc = "Redirect Cmdline",
			},
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
				"<leader>n",
				function()
					require("noice").cmd("dismiss")
				end,
				desc = "Dismiss All",
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
			"rcarriga/nvim-notify",
		},
	},
	--- }}}
	-- {{{ Nvim-notify                     UI - Notifications framework (used by noice.nvim)
	{
		"rcarriga/nvim-notify",
		event = "VeryLazy",
		config = function()
			local notify = require("notify")
			notify.setup({
				render = "minimal",
				stages = "static", -- can be: static, slide, fade, fade_in_slide_out
				timeout = 800,
			})
		end,
	},
	--- }}}
	-- {{{ Which-Key                       UI - The (another Emacs stolen) plugin that shows pending keybindings
	{
		"folke/which-key.nvim",
		config = function()
			local wk = require("which-key")

			wk.add({
				{ "<leader>c", group = "[C]ode" },
				{ "<leader>c_", hidden = true },
				{ "<leader>d", group = "[D]ocument / [D]AP" },
				{ "<leader>d_", hidden = true },
				{ "<leader>g", group = "[G]it" },
				{ "<leader>g_", hidden = true },
				{ "<leader>b", group = "[B]uffer" },
				{ "<leader>b_", hidden = true },
				{ "<leader>r", group = "[R]ename" },
				{ "<leader>r_", hidden = true },
				{ "<leader>s", group = "[S]earch" },
				{ "<leader>s_", hidden = true },
				{ "<leader>sn", group = "[N]oice" },
				{ "<leader>t", group = "[T]oggle" },
				{ "<leader>t_", hidden = true },
				{ "<leader>tl", ":set number! norelativenumber<cr>", desc = "Toggle line number" },
				{ "<leader>tr", ":set relativenumber!<cr>", desc = "Toggle relative line number" },
				{ "<leader>w", group = "[W]orkspace" },
				{ "<leader>w_", hidden = true },
				{ "<{leader>h", group = "More git" },
				{ "<{leader>h_", hidden = true },
			})

			wk.setup({
				win = {
					border = "rounded", -- none, single, double, shadow
					padding = { 2, 2, 2, 2 }, -- extra window padding [top, right, bottom, left]
					wo = {
						winblend = 0,
					},
				},
				layout = {
					height = { min = 4, max = 25 }, -- min and max height of the columns
					width = { min = 20, max = 50 }, -- min and max width of the columns
					spacing = 3, -- spacing between columns
					align = "center", -- align columns left, center or right
				},
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
				telescope = true,
				treesitter = true,
				treesitter_context = true,
				which_key = true,
				rainbow_delimiters = true,
				fidget = true,
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

			keymap.set("n", "<leader>wr", "<cmd>SessionRestore<CR>", { desc = "[W]orkspace [R]estore session for cwd" }) -- restore last workspace session for current directory
			keymap.set(
				"n",
				"<leader>ws",
				"<cmd>SessionSave<CR>",
				{ desc = "[W]orkspace [S]ave session for auto session root dir" }
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
	-- {{{ Neogit                          VC - A git interface based on Emacs Magit
	{
		"NeogitOrg/neogit",
		event = "VeryLazy",
		config = function()
			local neogit = require("neogit")
			neogit.setup({
				graph_style = "unicode", -- was ascii
			})

			vim.api.nvim_set_keymap(
				"n",
				"<leader>gg",
				":Neogit<CR>",
				{ noremap = true, silent = true, desc = "neo[G]it" }
			)
		end,
		dependencies = {
			"nvim-lua/plenary.nvim", -- required
			"sindrets/diffview.nvim", -- optional - Diff integration

			-- Only one of these is needed.
			"nvim-telescope/telescope.nvim", -- optional
			-- "ibhagwan/fzf-lua", -- optional
			-- "echasnovski/mini.pick", -- optional
		},
	},
	-- }}},
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
			end, { desc = "[G]it [D]iff with diffview" })

			local diffview = require("diffview")
			diffview.setup({
				hg_cmd = { "" },
			})
		end,
	},
	-- }}},
	-- {{{ Gitsigns                        VC - Adds git gutter / hunk blame&diff
	{
		-- Adds git related signs to the gutter, as well as utilities for managing changes
		"lewis6991/gitsigns.nvim",
		opts = {
			-- See `:help gitsigns.txt`
			-- signs = {
			-- add = { text = '+' },
			-- change = { text = '~' },
			-- delete = { text = '_' },
			-- topdelete = { text = '‾' },
			-- changedelete = { text = '~' },
			-- },
			signs = {
				add = { text = "│" },
				change = { text = "│" },
				delete = { text = "_" },
				topdelete = { text = "‾" },
				changedelete = { text = "~" },
				untracked = { text = "┆" },
			},

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
						return "]c"
					end
					vim.schedule(function()
						gs.next_hunk()
					end)
					return "<Ignore>"
				end, { expr = true })

				map("n", "[c", function()
					if vim.wo.diff then
						return "[c"
					end
					vim.schedule(function()
						gs.prev_hunk()
					end)
					return "<Ignore>"
				end, { expr = true })

				vim.keymap.set({ "n", "v" }, "]c", function()
					if vim.wo.diff then
						return "]c"
					end
					vim.schedule(function()
						gs.next_hunk()
					end)
					return "<Ignore>"
				end, { expr = true, buffer = bufnr, desc = "Jump to next hunk" })
				vim.keymap.set({ "n", "v" }, "[c", function()
					if vim.wo.diff then
						return "[c"
					end
					vim.schedule(function()
						gs.prev_hunk()
					end)
					return "<Ignore>"
				end, { expr = true, buffer = bufnr, desc = "Jump to previous hunk" })

				-- Actions
				map({ "n", "v" }, "<leader>hs", ":Gitsigns stage_hunk<CR>", { desc = "[H]unk [S]tage" })
				map({ "n", "v" }, "<leader>hr", ":Gitsigns reset_hunk<CR>", { desc = "[H]unk [R]eset" })
				map("n", "<leader>hS", gs.stage_buffer, { desc = "[S]tage buffer" })
				map("n", "<leader>ha", gs.stage_hunk, { desc = "Stage [A] hunk" })
				map("n", "<leader>hu", gs.undo_stage_hunk, { desc = "[U]ndo stage hunk" })
				map("n", "<leader>hR", gs.reset_buffer, { desc = "[R]eset Buffer" })
				map("n", "<leader>hp", gs.preview_hunk, { desc = "[P]review [H]unk" })
				map("n", "<leader>hb", function()
					gs.blame_line({ full = true })
				end, { desc = "[B]lame Line" })
				map("n", "<leader>tB", gs.toggle_current_line_blame, { desc = "[T]oggle [B]lame line" })
				map("n", "<leader>hd", gs.diffthis, { desc = "[H]unk [D]iff this" })
				map("n", "<leader>hD", function()
					gs.diffthis("~")
				end, { desc = "[h]unk Diff this" })
			end,
		},
	},
	-- }}}
}, {
	-- {{{ Lazy Package Manager UI
	ui = {
		border = "rounded",
	},
	rocks = {
		enabled = false,
	},
	-- }}}
})

-- {{{ Classic VIM Configs             VIM - Options / Keymaps
vim.o.hlsearch = true
vim.wo.number = true
vim.o.mouse = "a"
vim.o.clipboard = "unnamedplus"
vim.o.breakindent = true
vim.o.undofile = true
vim.o.ignorecase = true
vim.o.smartcase = true
vim.wo.signcolumn = "yes"
vim.o.updatetime = 250
vim.o.timeoutlen = 1000
vim.o.completeopt = "menuone,noselect"
vim.o.wrap = false
vim.cmd.colorscheme("catppuccin")
vim.o.scrolloff = 8
vim.o.relativenumber = true -- Toggle with <leader>tr
vim.o.showtabline = 0 -- Toggle Tabs with <leader>tt
vim.o.swapfile = false
vim.o.backspace = "indent,eol,start" -- Allow backspace on ident
vim.o.cursorline = true
vim.o.splitright = true
vim.o.splitbelow = true
vim.o.laststatus = 3
vim.opt.spelllang = { "en", "pt_br" }
vim.o.spell = false

vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<cr>")
vim.keymap.set("i", "jj", "<Esc>")
vim.keymap.set({ "n", "v" }, "<C-d>", "<C-d>zz", { silent = true })
vim.keymap.set({ "n", "v" }, "<C-u>", "<C-u>zz", { silent = true })
vim.keymap.set("n", "k", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
vim.keymap.set("n", "j", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })
vim.keymap.set("n", "<S-l>", ":bnext<CR>", { desc = "Next buffer", silent = true })
vim.keymap.set("n", "<S-h>", ":bprev<CR>", { desc = "Previous buffer", silent = true })
vim.keymap.set("n", "]b", ":bnext<CR>", { desc = "Next buffer", silent = true })
vim.keymap.set("n", "[b", ":bprev<CR>", { desc = "Previous buffer", silent = true })
vim.keymap.set("n", "]q", ":cnext<CR>", { desc = "Next quickfix item", silent = true })
vim.keymap.set("n", "[q", ":cprev<CR>", { desc = "Previous quickfix item", silent = true })
vim.keymap.set("n", "[d", function()
	vim.diagnostic.jump({ count = -1, float = true })
end, { desc = "Go to previous diagnostic message" })
vim.keymap.set("n", "]d", function()
	vim.diagnostic.jump({ count = 1, float = true })
end, { desc = "Go to next diagnostic message" })
vim.keymap.set("n", "<leader>dm", vim.diagnostic.open_float, { desc = "Open floating diagnostic message" })
vim.keymap.set("n", "<leader>ta", "<cmd>AerialToggle!<CR>", { desc = "Toggle aerial" })
vim.keymap.set("n", "<leader>tc", "<cmd>TSContextToggle<CR>", { desc = "Toggle treesitter context" })
vim.keymap.set("n", "<leader>tI", "<cmd>IndentationLineToggle<CR>", { desc = "Toggle indent line" })

vim.keymap.set("n", "<leader>ti", function()
	local virtual_text = vim.diagnostic.config().virtual_text
	vim.diagnostic.config({ virtual_text = not virtual_text })
end, { desc = "Toggle inline diagnostics" })

vim.keymap.set("n", "<leader>td", function()
	vim.diagnostic.enable(not vim.diagnostic.is_enabled())
end, { desc = "Toggle diagnostics" })

vim.keymap.set("n", "<leader>tt", function()
	if vim.o.showtabline == 2 then
		vim.o.showtabline = 0
	else
		vim.o.showtabline = 2
	end
end, { desc = "Toggle tabs" })

vim.keymap.set("n", "<leader>bx", ":bd<CR>", { desc = "Close buffer", silent = true })
vim.keymap.set("n", "<leader>bX", ":bufdo bd<CR>", { desc = "Close all buffers", silent = true })

local highlight_group = vim.api.nvim_create_augroup("YankHighlight", { clear = true })
vim.api.nvim_create_autocmd("TextYankPost", {
	callback = function()
		vim.highlight.on_yank()
	end,
	group = highlight_group,
	pattern = "*",
})

vim.diagnostic.config({
	float = { border = "rounded" },
	signs = {
		text = {
			[vim.diagnostic.severity.ERROR] = "󰅚 ",
			[vim.diagnostic.severity.WARN] = "󰀪 ",
			[vim.diagnostic.severity.HINT] = "󰌶 ",
			[vim.diagnostic.severity.INFO] = " ",
		},
	},
})

--- }}}
-- vim: ts=2 sts=2 sw=2 et fileencoding=utf-8:foldmethod=marker
