-- Set the leader key to space
vim.g.mapleader = " "

vim.opt.nu = true
vim.opt.relativenumber = true
vim.opt.clipboard = "unnamedplus" -- use system clipboard
vim.opt.completeopt = { "menu", "menuone", "noselect" }
vim.opt.mouse = ""

vim.opt.tabstop = 2
vim.opt.softtabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true

vim.opt.smartindent = true

vim.opt.wrap = false

vim.opt.swapfile = false
vim.opt.backup = false
--vim.opt.undodir = os.getenv("HOME") .. "/.vim/undodir"
vim.opt.undofile = true

vim.opt.hlsearch = false
vim.opt.incsearch = true

vim.opt.termguicolors = true

vim.opt.scrolloff = 8
vim.opt.signcolumn = "yes"
vim.opt.isfname:append("@-@")

vim.opt.updatetime = 50

vim.opt.colorcolumn = "80"

vim.opt.cursorline = true -- highlight cursor line underneath the cursor horizontally
vim.opt.splitbelow = true -- open new vertical split bottom
vim.opt.splitright = true -- open new horizontal splits right

vim.opt.incsearch = true -- search as characters are entered
vim.opt.ignorecase = true -- ignore case in searches by default
vim.opt.smartcase = true -- but make it case sensitive if an uppercase is entered

vim.keymap.set("n", "<leader>ff", function()
	require("fzf-lua").files()
end, { noremap = true, silent = true })

vim.keymap.set("n", "<leader>fw", function()
	require("fzf-lua").grep_cword()
end, { noremap = true, silent = true })

vim.keymap.set("n", "<leader>fg", function()
	require("fzf-lua").git_files()
end, { noremap = true, silent = true })

vim.keymap.set("n", "<leader>gg", function()
	require("fzf-lua").git_commits()
end, { noremap = true, silent = true })

vim.keymap.set("n", "<leader>gs", function()
	require("fzf-lua").git_status()
end, { noremap = true, silent = true })

vim.keymap.set("n", "<leader>gb", function()
	require("fzf-lua").git_blame()
end, { noremap = true, silent = true })
