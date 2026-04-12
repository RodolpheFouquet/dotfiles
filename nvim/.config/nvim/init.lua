vim.g.mapleader = " "

vim.opt.clipboard = "unnamedplus"
vim.opt.expandtab = true
vim.opt.mouse = ""
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.shiftwidth = 2
vim.opt.tabstop = 2
vim.opt.termguicolors = true

require("lazy").setup({
    { "folke/tokyonight.nvim" },
    { "nvim-lualine/lualine.nvim" },
    { "nvim-tree/nvim-web-devicons" },
    { "folke/lsp-lines.nvim" },
    { "ThePrimeagen/harpoon", branch = "master" },
    { "theHamsta/nvim-dap-virtual-text" },
    { "rcarriga/nvim-dap-ui" },
    { "rcarriga/dap-python", ft = { "python" } },
    { "leoluz/nvim-dap-go" },
    { "stevearc/conform.nvim" },
    { "nvim-treesitter/nvim-treesitter", build = ":TSUpdate" },
    { "nvim-telescope/telescope.nvim", tag = "0.1.x" },
    { "nvim-telescope/telescope-dap.nvim" },
    { "nvim-telescope/telescope-harpoon" },
    {
        "RRethy/base16-nvim",
        priority = 1000,
        config = function()
            require('base16-colorscheme').setup({
                base00 = '#1f1d2e',
                base01 = '#1f1d2e',
                base02 = '#908a96',
                base03 = '#908a96',
                base04 = '#eae3f2',
                base05 = '#fbf8ff',
                base06 = '#fbf8ff',
                base07 = '#fbf8ff',
                base08 = '#ff9fb1',
                base09 = '#ff9fb1',
                base0A = '#ddc2fe',
                base0B = '#a5ffba',
                base0C = '#eddfff',
                base0D = '#ddc2fe',
                base0E = '#e3cdff',
                base0F = '#e3cdff',
            })

            vim.api.nvim_set_hl(0, 'Visual', {
                bg = '#908a96',
                fg = '#fbf8ff',
                bold = true
            })
            vim.api.nvim_set_hl(0, 'Statusline', {
                bg = '#ddc2fe',
                fg = '#1f1d2e',
            })
            vim.api.nvim_set_hl(0, 'LineNr', { fg = '#908a96' })
            vim.api.nvim_set_hl(0, 'CursorLineNr', { fg = '#eddfff', bold = true })

            vim.api.nvim_set_hl(0, 'Statement', {
                fg = '#e3cdff',
                bold = true
            })
            vim.api.nvim_set_hl(0, 'Keyword', { link = 'Statement' })
            vim.api.nvim_set_hl(0, 'Repeat', { link = 'Statement' })
            vim.api.nvim_set_hl(0, 'Conditional', { link = 'Statement' })

            vim.api.nvim_set_hl(0, 'Function', {
                fg = '#ddc2fe',
                bold = true
            })
            vim.api.nvim_set_hl(0, 'Macro', {
                fg = '#ddc2fe',
                italic = true
            })
            vim.api.nvim_set_hl(0, '@function.macro', { link = 'Macro' })

            vim.api.nvim_set_hl(0, 'Type', {
                fg = '#eddfff',
                bold = true,
                italic = true
            })
            vim.api.nvim_set_hl(0, 'Structure', { link = 'Type' })

            vim.api.nvim_set_hl(0, 'String', {
                fg = '#a5ffba',
                italic = true
            })

            vim.api.nvim_set_hl(0, 'Operator', { fg = '#eae3f2' })
            vim.api.nvim_set_hl(0, 'Delimiter', { fg = '#eae3f2' })
            vim.api.nvim_set_hl(0, '@punctuation.bracket', { link = 'Delimiter' })
            vim.api.nvim_set_hl(0, '@punctuation.delimiter', { link = 'Delimiter' })

            vim.api.nvim_set_hl(0, 'Comment', {
                fg = '#908a96',
                italic = true
            })
        end,
    },
}, { performance = { rtp = { reset = false } } })

vim.cmd([[let $BAT_THEME = 'tokyonight'
colorscheme tokyonight
]])

vim.diagnostic.config({
    signs = { enable = true },
    underline = { enable = true },
    virtualText = { enable = false, severityMin = "Warn" },
    virtual_text = false,
})

require("nvim-treesitter.configs").setup({
    highlight = { enable = true },
    indent = { enable = true },
})

require("telescope").setup({})
require("telescope").load_extension("harpoon")
require("telescope").load_extension("dap")

require("lualine").setup({})

require("lsp-lines").setup()

require("harpoon"):setup({})

require("nvim-dap-virtual-text").setup({})

require("dapui").setup({
    icons = {
        expanded = "▾",
        collapsed = "▸",
        current_frame = "▸",
    },
    mappings = {
        expand = { "<CR>", "<2-LeftMouse>" },
        open = "o",
        remove = "d",
        edit = "e",
        repl = "r",
        toggle = "t",
    },
    layouts = {
        {
            elements = {
                { id = "scopes", size = 0.25 },
                "breakpoints",
                "stacks",
                "watches",
            },
            size = 40,
            position = "left",
        },
        {
            elements = {
                "repl",
                "console",
            },
            size = 0.25,
            position = "bottom",
        },
    },
})

require("dap-python").setup()

require("dap-go").setup({})

require("conform").setup({
    format_on_save = { lsp_fallback = true, timeout_ms = 500 },
    formatters_by_ft = {
        c = { "clang-format" },
        cpp = { "clang-format" },
        elixir = { "mix" },
        gleam = { "gleam" },
        go = { "gofmt" },
        nix = { "nixfmt" },
        python = { "ruff_format" },
        rust = { "rustfmt" },
        typescript = { "prettier" },
        zig = { "zig" },
    },
})

vim.keymap.set("n", "<leader>ff", "<cmd>Telescope find_files<cr>", { desc = "Find Files" })
vim.keymap.set("n", "<leader>fg", "<cmd>Telescope live_grep<cr>", { desc = "Live Grep" })
vim.keymap.set("n", "<leader>a", "<cmd>lua require('harpoon.mark').add_file()<cr>", { desc = "Harpoon Add File" })
vim.keymap.set("n", "<C-e>", "<cmd>lua require('harpoon.ui').toggle_quick_menu()<cr>", { desc = "Harpoon Quick Menu" })
vim.keymap.set("n", "<C-h>", "<cmd>lua require('harpoon.ui').nav_file(1)<cr>", { desc = "Harpoon File 1" })
vim.keymap.set("n", "<C-j>", "<cmd>lua require('harpoon.ui').nav_file(2)<cr>", { desc = "Harpoon File 2" })
vim.keymap.set("n", "<C-k>", "<cmd>lua require('harpoon.ui').nav_file(3)<cr>", { desc = "Harpoon File 3" })
vim.keymap.set("n", "<C-l>", "<cmd>lua require('harpoon.ui').nav_file(4)<cr>", { desc = "Harpoon File 4" })
vim.keymap.set("n", "<leader>db", "<cmd>DapToggleBreakpoint<cr>", { desc = "Toggle Breakpoint" })
vim.keymap.set("n", "<leader>dB", "<cmd>lua require('dap').set_breakpoint(vim.fn.input('Breakpoint condition: '))<cr>", { desc = "Set Conditional Breakpoint" })
vim.keymap.set("n", "<leader>dc", "<cmd>DapContinue<cr>", { desc = "Continue" })
vim.keymap.set("n", "<leader>do", "<cmd>DapStepOver<cr>", { desc = "Step Over" })
vim.keymap.set("n", "<leader>di", "<cmd>DapStepInto<cr>", { desc = "Step Into" })
vim.keymap.set("n", "<leader>du", "<cmd>DapStepOut<cr>", { desc = "Step Out" })
vim.keymap.set("n", "<leader>dr", "<cmd>DapToggleRepl<cr>", { desc = "Toggle REPL" })
vim.keymap.set("n", "<leader>dl", "<cmd>DapRunLast<cr>", { desc = "Run Last" })
vim.keymap.set("n", "<leader>dt", "<cmd>DapTerminate<cr>", { desc = "Terminate" })
vim.keymap.set("n", "<leader>dui", "<cmd>lua require('dapui').toggle()<cr>", { desc = "Toggle DAP UI" })
vim.keymap.set("n", "<leader>dcc", "<cmd>Telescope dap commands<cr>", { desc = "DAP Commands" })
vim.keymap.set("n", "<leader>dco", "<cmd>Telescope dap configurations<cr>", { desc = "DAP Configurations" })
vim.keymap.set("n", "<leader>dv", "<cmd>Telescope dap variables<cr>", { desc = "DAP Variables" })
vim.keymap.set("n", "<leader>df", "<cmd>Telescope dap frames<cr>", { desc = "DAP Frames" })

vim.lsp.inlay_hint.enable(true)

vim.lsp.config("clangd", {})
vim.lsp.enable("clangd")
vim.lsp.config("elixirls", {})
vim.lsp.enable("elixirls")
vim.lsp.config("gleam", {})
vim.lsp.enable("gleam")
vim.lsp.config("gopls", {})
vim.lsp.enable("gopls")
vim.lsp.config("nixd", {})
vim.lsp.enable("nixd")
vim.lsp.config("ocamllsp", {})
vim.lsp.enable("ocamllsp")
vim.lsp.config("pyright", {})
vim.lsp.enable("pyright")
vim.lsp.config("rust_analyzer", {})
vim.lsp.enable("rust_analyzer")
vim.lsp.config("ts_ls", {
    filetypes = {
        "javascript",
        "javascriptreact",
        "javascript.jsx",
        "typescript",
        "typescriptreact",
        "typescript.tsx",
    },
})
vim.lsp.enable("ts_ls")
vim.lsp.config("zls", {})
vim.lsp.enable("zls")

local dap = require("dap")
local dapui = require("dapui")
local telescope = require("telescope")

telescope.load_extension("dap")

require("dap-go").setup()

dap.listeners.after.event_initialized["dapui_config"] = function()
    dapui.open()
end
dap.listeners.before.event_terminated["dapui_config"] = function()
    dapui.close()
end
dap.listeners.before.event_exited["dapui_config"] = function()
    dapui.close()
end

dap.configurations.rust = {
    {
        name = "Launch Rust",
        type = "codelldb",
        request = "launch",
        program = function()
            return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/target/debug/", "file")
        end,
        cwd = vim.fn.getcwd(),
        stopOnEntry = false,
        args = {},
        runInTerminal = false,
    },
}

dap.configurations.c = {
    {
        name = "Launch C",
        type = "codelldb",
        request = "launch",
        program = function()
            return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
        end,
        cwd = vim.fn.getcwd(),
        stopOnEntry = false,
        args = {},
    },
}

dap.configurations.cpp = dap.configurations.c

dap.configurations.python = {
    {
        name = "Launch Python",
        type = "python",
        request = "launch",
        program = vim.fn.expand("%:p"),
        console = "integratedTerminal",
        cwd = vim.fn.getcwd(),
    },
}

dap.configurations.zig = {
    {
        name = "Launch Zig",
        type = "codelldb",
        request = "launch",
        program = function()
            return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/zig-out/bin/", "file")
        end,
        cwd = vim.fn.getcwd(),
        stopOnEntry = false,
        args = {},
    },
}

dap.configurations.typescript = {
    {
        name = "Launch Node.js",
        type = "pwa-node",
        request = "launch",
        program = vim.fn.expand("%:p"),
        cwd = vim.fn.getcwd(),
        sourceMaps = true,
        protocol = "inspector",
        console = "integratedTerminal",
    },
}

dap.configurations.javascript = {
    {
        name = "Launch Node.js",
        type = "pwa-node",
        request = "launch",
        program = vim.fn.expand("%:p"),
        cwd = vim.fn.getcwd(),
        console = "integratedTerminal",
    },
}

local nixvim_lsp_on_attach = vim.api.nvim_create_augroup("nixvim_lsp_on_attach", { clear = false })
vim.api.nvim_create_autocmd("LspAttach", {
    group = nixvim_lsp_on_attach,
    callback = function(args)
        local client = vim.lsp.get_client_by_id(args.data.client_id)
        local bufnr = args.buf

        vim.keymap.set("n", "K", vim.lsp.buf.hover, { buffer = bufnr, desc = "Lsp buf hover" })
        vim.keymap.set("n", "ca", vim.lsp.buf.code_action, { buffer = bufnr, desc = "Lsp buf code_action" })
        vim.keymap.set("n", "gD", vim.lsp.buf.declaration, { buffer = bufnr, desc = "Lsp buf declaration" })
        vim.keymap.set("n", "gd", vim.lsp.buf.definition, { buffer = bufnr, desc = "Lsp buf definition" })
        vim.keymap.set("n", "gi", vim.lsp.buf.implementation, { buffer = bufnr, desc = "Lsp buf implementation" })
        vim.keymap.set("n", "gr", vim.lsp.buf.references, { buffer = bufnr, desc = "Lsp buf references" })
    end,
})
