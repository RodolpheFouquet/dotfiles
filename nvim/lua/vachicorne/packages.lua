-- Use 'mini.deps'. `now()` and `later()` are helpers for a safe two-stage
-- startup and are optional.
local add, now, later = MiniDeps.add, MiniDeps.now, MiniDeps.later

-- Safely execute immediately
now(function()
	add({
		source = "eldritch-theme/eldritch.nvim",
	})
end)

now(function()
	add({
		source = "dstein64/vim-startuptime",
	})
end)

now(function()
	vim.o.termguicolors = true
	vim.cmd("colorscheme eldritch")
end)

now(function()
	-- Setup mini.notify (optional, but nice)
	add({ source = "echasnovski/mini.nvim" }) -- Ensure mini.nvim is added if not already
	require("mini.notify").setup()
	vim.notify = require("mini.notify").make_notify()
end)

-- Load other mini modules you use
now(function()
	require("mini.icons").setup()
end)
now(function()
	require("mini.tabline").setup()
end)
now(function()
	require("mini.statusline").setup()
end)

now(function()
	add({
		source = "ibhagwan/fzf-lua",
		dependencies = { "echasnovski/mini.icons" },
	})
	require("fzf-lua").setup({})
end)

-- === Formatting Setup (Conform) ===
now(function()
	add({
		source = "stevearc/conform.nvim",
		event = { "BufWritePre" }, -- Optimize loading
		cmd = { "ConformInfo" },
	})

	require("conform").setup({
		-- Map filetypes to formatters
		formatters_by_ft = {
			lua = { "stylua" },
			ocaml = { "ocamlformat" },
			python = { "ruff" }, -- Use ruff for Python formatting
			javascript = { "prettier" },
			typescript = { "prettier" },
			css = { "prettier" },
			html = { "prettier" },
			json = { "prettier" },
		},
		-- Global configuration for formatters
		formatters = {
			ocamlformat = {
				prepend_args = {
					"--if-then-else",
					"vertical",
					"--break-cases",
					"fit-or-vertical",
					"--type-decl",
					"sparse",
				},
			},
			ruff = {
				-- Ruff args can be configured here or in pyproject.toml/ruff.toml
			},
			-- Configure other formatters if you add them
			prettier = {
				prepend_args = { "--config-path", vim.fn.stdpath("config") .. "/.prettierrc.json" },
			},
		},
		-- Enable format-on-save
		format_on_save = {
			timeout_ms = 500,
			lsp_fallback = true, -- **Important**: Fallback to LSP formatting only if conform fails or no formatter is found
		},
		-- Optional: Log level for debugging
		-- log_level = vim.log.levels.DEBUG,
	})

	-- Optional: Add a keymap for manual formatting (if not already in on_attach)
	-- This allows formatting even if LSP isn't attached or for filetypes without LSP
	vim.keymap.set({ "n", "v" }, "<leader>cf", function()
		require("conform").format({ async = true, lsp_fallback = true })
	end, { desc = "Format buffer with Conform" })
end)

-- === LSP Setup (Mason, LSPConfig, Ruff, Pyright) ===
now(function()
	-- Add core LSP plugins
	add({ source = "neovim/nvim-lspconfig" })
	add({ source = "williamboman/mason.nvim" })
	add({ source = "williamboman/mason-lspconfig.nvim" })
	-- Add completion engine (example: nvim-cmp) - Assuming you might want this later
	add({ source = "hrsh7th/nvim-cmp" })
	add({ source = "hrsh7th/cmp-nvim-lsp" })
	add({ source = "hrsh7th/cmp-buffer" })
	add({ source = "hrsh7th/cmp-path" })
	add({ source = "hrsh7th/cmp-cmdline" })
	add({ source = "L3MON4D3/LuaSnip" }) -- Snippet engine
	add({ source = "saadparwaiz1/cmp_luasnip" }) -- Snippet source for nvim-cmp
end)

-- Define the on_attach function for LSP servers
local on_attach = function(client, bufnr)
	-- Standard LSP keymaps (consider moving these to mappings.lua if preferred)
	local bufopts = { noremap = true, silent = true, buffer = bufnr }
	vim.keymap.set("n", "gD", vim.lsp.buf.declaration, bufopts)
	vim.keymap.set("n", "gd", vim.lsp.buf.definition, bufopts)
	vim.keymap.set("n", "K", vim.lsp.buf.hover, bufopts)
	vim.keymap.set("n", "gi", vim.lsp.buf.implementation, bufopts)
	vim.keymap.set("n", "<C-k>", vim.lsp.buf.signature_help, bufopts) -- Use Ctrl-k for signature help
	vim.keymap.set("n", "<leader>wa", vim.lsp.buf.add_workspace_folder, bufopts)
	vim.keymap.set("n", "<leader>wr", vim.lsp.buf.remove_workspace_folder, bufopts)
	vim.keymap.set("n", "<leader>wl", function()
		print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
	end, bufopts)
	vim.keymap.set("n", "<leader>D", vim.lsp.buf.type_definition, bufopts) -- Use <leader>D for type definition
	vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, bufopts)
	vim.keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, bufopts) -- Use <leader>ca for code action
	vim.keymap.set("n", "gr", vim.lsp.buf.references, bufopts)

	-- Keymap for formatting via conform (uses Ruff for Python)
	-- This keymap is buffer-local and relies on LSP being attached,
	-- but conform's format_on_save handles automatic formatting.
	-- The global <leader>cf keymap is also available.
	vim.keymap.set({ "n", "v" }, "<leader>fd", function()
		require("conform").format({ async = true, lsp_fallback = true })
	end, { desc = "Format buffer [LSP]", buffer = bufnr })

	-- === Specific LSP Server Adjustments ===

	-- Disable Ruff's hover provider to prefer Pyright's richer info
	if client.name == "ruff" then
		client.server_capabilities.hoverProvider = false
		-- Optional: Disable Ruff diagnostics if they overlap too much with Pyright
		-- You might need to experiment based on your Ruff config (pyproject.toml)
		-- client.server_capabilities.diagnosticProvider = nil -- Disables all Ruff diagnostics via LSP
	end

	-- Enable inlay hints for Rust Analyzer (example)
	if client.name == "rust_analyzer" then
		vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
	end

	-- Add other client-specific settings here if needed

	-- Set omnifunc for built-in completion <C-x><C-o> (optional if using nvim-cmp)
	vim.api.nvim_buf_set_option(bufnr, "omnifunc", "v:lua.vim.lsp.omnifunc")

	-- Optional: Highlight symbol under cursor
	vim.api.nvim_create_autocmd("CursorHold", {
		buffer = bufnr,
		callback = function()
			vim.lsp.buf.document_highlight()
		end,
	})
	vim.api.nvim_create_autocmd("CursorMoved", {
		buffer = bufnr,
		callback = function()
			vim.lsp.buf.clear_references()
		end,
	})
end

-- Configure Mason and Mason-LSPConfig
later(function()
	require("mason").setup({
		ui = {
			border = "rounded",
		},
		-- Optional: Log level for debugging Mason
		-- log_level = vim.log.levels.DEBUG,
	})

	require("mason-lspconfig").setup({
		-- Ensure these servers are installed automatically by Mason
		ensure_installed = {
			"lua_ls",
			"rust_analyzer",
			"ocamllsp",
			"pyright",
			"ruff",
			"ts_ls",
			"ocamllsp",
			"gopls",
		},
		-- Automatic setup integrates mason-lspconfig with nvim-lspconfig
		automatic_installation = true,
	})
end)

-- Configure LSP Servers using nvim-lspconfig
later(function()
	local lspconfig = require("lspconfig")
	local capabilities = vim.lsp.protocol.make_client_capabilities()
	-- If using nvim-cmp, uncomment the following line to add its capabilities
	capabilities = require("cmp_nvim_lsp").default_capabilities(capabilities)

	-- Lua LSP
	lspconfig.lua_ls.setup({
		capabilities = capabilities,
		on_attach = on_attach,
		settings = {
			Lua = {
				runtime = { version = "LuaJIT" },
				diagnostics = { globals = { "vim" } },
				workspace = { library = vim.api.nvim_get_runtime_file("", true) },
				telemetry = { enable = false },
			},
		},
	})

	-- Rust LSP
	lspconfig.rust_analyzer.setup({
		capabilities = capabilities,
		on_attach = on_attach,
		-- Add specific Rust Analyzer settings if needed
		settings = {
			["rust-analyzer"] = {
				-- Example: Enable clippy checks
				checkOnSave = {
					command = "clippy",
				},
			},
		},
	})

	-- OCaml LSP
	lspconfig.ocamllsp.setup({
		capabilities = capabilities,
		on_attach = on_attach,
	})

	-- TypeScript/JavaScript LSP (Example)
	lspconfig.ts_ls.setup({
		capabilities = capabilities,
		on_attach = on_attach,
	})

	-- === Python LSP Setup (Pyright + Ruff) ===

	-- Pyright LSP (for type checking, completions, hover, etc.)
	lspconfig.pyright.setup({
		capabilities = capabilities,
		on_attach = on_attach,
		settings = {
			python = {
				analysis = {
					-- Optional: Adjust type checking strictness if needed
					-- typeCheckingMode = "basic", -- "off", "basic", "strict"
					-- Optional: Auto-search paths for imports (useful for monorepos)
					-- autoSearchPaths = true,
					-- Optional: Use library code for types if stubs are missing
					-- useLibraryCodeForTypes = true,
					-- Optional: Specify paths to look for stubs
					-- stubPath = "./stubs",
				},
			},
			pyright = {
				-- Optional: Disable diagnostics if they overlap too much with Ruff
				-- disableOrganizeImports = true, -- If you prefer ruff/isort for imports
			},
		},
	})

	-- Ruff LSP (primarily for fast linting diagnostics)
	lspconfig.ruff.setup({
		capabilities = capabilities,
		on_attach = on_attach,
		-- No specific settings needed here usually, as formatting is handled by conform
		-- and hover is disabled in on_attach.
		-- Diagnostics are controlled by your ruff config (pyproject.toml / ruff.toml)
	})

	require("lspconfig").qmlls.setup({
		cmd = { "qmlls6", "-E" },
	})
end)

-- === Other Plugins ===

-- Treesitter
later(function()
	add({
		source = "nvim-treesitter/nvim-treesitter",
		run = ":TSUpdate", -- Run TSUpdate command automatically on update/install
		config = function()
			require("nvim-treesitter.configs").setup({
				ensure_installed = {
					"lua",
					"vim",
					"vimdoc",
					"python",
					"rust",
					"ocaml",
					"typescript",
					"javascript",
					"html",
					"css",
					"json",
					"toml",
					"yaml",
					"markdown",
					"bash",
					"qmljs",
					"qmldir",
					"go",
					-- Add other languages you use
				},
				-- Enable syntax highlighting
				highlight = { enable = true },
				-- Enable indentation based on treesitter nodes
				indent = { enable = true },
				-- Optional: Enable other modules like incremental selection, etc.
				-- incremental_selection = {
				--   enable = true,
				--   keymaps = {
				--     init_selection = "<c-space>",
				--     node_incremental = "<c-space>",
				--     scope_incremental = "<c-s>",
				--     node_decremental = "<c-backspace>",
				--   },
				-- },
			})
		end,
	})
end)

-- Trouble (for diagnostics)
later(function()
	add({
		source = "folke/trouble.nvim",
		dependencies = { "nvim-tree/nvim-web-devicons" }, -- Optional dependency for icons
		config = function()
			require("trouble").setup({
				-- Configuration options for Trouble (see :help trouble)
				icons = true, -- Use devicons
				mode = "workspace_diagnostics", -- Default mode
				-- etc.
			})
			-- Keymaps for Trouble
			vim.keymap.set("n", "<leader>xx", function()
				require("trouble").toggle()
			end, { desc = "Toggle Trouble diagnostics" })
			vim.keymap.set("n", "<leader>xw", function()
				require("trouble").toggle("workspace_diagnostics")
			end, { desc = "Workspace diagnostics" })
			vim.keymap.set("n", "<leader>xd", function()
				require("trouble").toggle("document_diagnostics")
			end, { desc = "Document diagnostics" })
			vim.keymap.set("n", "<leader>xl", function()
				require("trouble").toggle("loclist")
			end, { desc = "Location list" })
			vim.keymap.set("n", "<leader>xq", function()
				require("trouble").toggle("quickfix")
			end, { desc = "Quickfix list" })
			vim.keymap.set("n", "gR", function()
				require("trouble").toggle("lsp_references")
			end, { desc = "LSP references in Trouble" })
			vim.keymap.set("n", "]t", function()
				require("trouble").next({ skip_groups = true, jump = true })
			end, { desc = "Next Trouble item" })
			vim.keymap.set("n", "[t", function()
				require("trouble").previous({ skip_groups = true, jump = true })
			end, { desc = "Previous Trouble item" })
		end,
	})
end)

-- Load other mini modules later if they don't need to run immediately
later(function()
	require("mini.ai").setup()
end)
later(function()
	require("mini.comment").setup()
end)
later(function()
	require("mini.surround").setup()
end)
later(function()
	require("mini.align").setup()
end)
-- later(function() require('mini.completion').setup() end) -- Consider nvim-cmp instead
later(function()
	require("mini.move").setup()
end)
later(function()
	require("mini.pairs").setup()
end)
later(function()
	require("mini.splitjoin").setup()
end)
later(function()
	require("mini.snippets").setup()
end) -- Consider LuaSnip instead
later(function()
	require("mini.operators").setup()
end)
later(function()
	require("mini.clue").setup()
end)
later(function()
	require("mini.extra").setup()
end)
later(function()
	require("mini.files").setup()
end)
later(function()
	require("mini.pick").setup()
end)
later(function()
	require("mini.indentscope").setup()
end)
later(function()
	require("mini.trailspace").setup()
end)

later(function()
	add({
		source = "theprimeagen/vim-be-good",
		dependencies = { "nvim-lua/plenary.nvim" },
	})
end)

later(function()
	add({
		source = "norcalli/nvim-colorizer.lua",
	})
end)
