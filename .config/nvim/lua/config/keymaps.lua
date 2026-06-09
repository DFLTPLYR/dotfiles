local keymap = vim.keymap.set
local s = { silent = true }

vim.g.mapleader = " "

keymap("n", "<space>", "<Nop>")

keymap("n", "j", function()
	return tonumber(vim.api.nvim_get_vvar("count")) > 0 and "j" or "gj"
end, { expr = true, silent = true })
keymap("n", "k", function()
	return tonumber(vim.api.nvim_get_vvar("count")) > 0 and "k" or "gk"
end, { expr = true, silent = true })

keymap("n", "<C-d>", "<C-d>zz")
keymap("n", "<C-u>", "<C-u>zz")

keymap("n", "<Leader>w", "<cmd>w!<CR>", s)
keymap("n", "<Leader>q", "<cmd>q<CR>", s)

keymap("i", "jj", "<ESC>", { desc = "exit insert mode" })
keymap("v", "<A-l>", ">gv", { desc = "Indent right" })
keymap("v", "<A-h>", "<gv", { desc = "Indent left" })
keymap("n", "<A-j>", "<cmd>m .+1<CR>==", { desc = "Move line down" })
keymap("v", "<A-j>", ":m '>+1<CR>gv=gv", { desc = "Move selection down" })
keymap("n", "<A-k>", "<cmd>m .-2<CR>==", { desc = "Move line up" })
keymap("v", "<A-k>", ":m '<-2<CR>gv=gv", { desc = "Move selection up" })

keymap("n", "<S-t>", "<cmd>tabnew<CR>", s)
keymap("n", "<S-l>", function()
	require("mini.visits").iterate_paths("backward")
end, s)
keymap("n", "<S-h>", function()
	require("mini.visits").iterate_paths("forward")
end, s)

keymap("n", "<Leader>fo", ":lua vim.lsp.buf.format()<CR>", s)
keymap("v", "<Leader>p", '"_dP')
keymap("x", "y", [["+y]], s)

keymap("n", "<leader>cd", '<cmd>lua vim.fn.chdir(vim.fn.expand("%:p:h"))<CR>')

local opts = { noremap = true, silent = true }
keymap("n", "grd", "<cmd>lua vim.lsp.buf.definition()<CR>", opts)

keymap("n", "<leader>ee", "<cmd>Pick files<CR>", { desc = "Pick file in current directory" })
keymap("n", "<leader>ff", "<cmd>FzfLua files<CR>")
keymap("n", "<leader>fg", "<cmd>FzfLua live_grep<CR>")

keymap("n", "<leader>gs", "<cmd>Git<CR>", opts)
keymap("n", "<leader>gp", "<cmd>Git push<CR>", opts)
