local keymap = vim.keymap.set
local s = { silent = true }

vim.g.mapleader = " "

keymap("n", "<space>", "<Nop>")
keymap("n", "s", "/")

keymap("n", "j", function()
	return tonumber(vim.api.nvim_get_vvar("count")) > 0 and "j" or "gj"
end, { expr = true, silent = true })
keymap("n", "k", function()
	return tonumber(vim.api.nvim_get_vvar("count")) > 0 and "k" or "gk"
end, { expr = true, silent = true })

keymap("n", "<C-d>", "<C-d>zz")
keymap("n", "<C-u>", "<C-u>zz")

keymap("n", "bd", function()
	require("mini.bufremove").delete()
	if #vim.api.nvim_list_bufs() == 0 then
		require("mini.starter").open()
	end
end, s)
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
keymap("n", "<S-h>", "<cmd>bprevious<cr>", { desc = "Prev Buffer" })
keymap("n", "<S-l>", "<cmd>bnext<cr>", { desc = "Next Buffer" })

keymap("n", "<Leader>fo", ":lua vim.lsp.buf.format()<CR>", s)
keymap("v", "<Leader>p", '"_dP')
keymap("x", "y", [["+y]], s)

keymap("n", "<leader>cd", '<cmd>lua vim.fn.chdir(vim.fn.expand("%:p:h"))<CR>')

local opts = { noremap = true, silent = true }
keymap("n", "grd", "<cmd>lua vim.lsp.buf.definition()<CR>", opts)

keymap("n", "<leader>ee", "<cmd>Pick files<CR>", { desc = "Pick file in current directory" })
keymap("n", "<leader>fe", "<cmd>Pick buffers<CR>", { desc = "Pick available buffers" })
keymap("n", "<leader>ff", "<cmd>FzfLua files<CR>")
keymap("n", "<leader>fg", "<cmd>FzfLua live_grep<CR>")

keymap("n", "<leader>gs", "<cmd>Git<CR>", opts)
keymap("n", "<leader>gp", "<cmd>Git push<CR>", opts)

local make_select_path = function(select_global, recency_weight)
	local visits = require("mini.visits")
	local sort = visits.gen_sort.default({ recency_weight = recency_weight })
	local select_opts = { sort = sort }
	return function()
		local cwd = select_global and "" or vim.fn.getcwd()
		visits.select_path(cwd, select_opts)
	end
end

local map = function(lhs, desc, ...)
	vim.keymap.set("n", lhs, make_select_path(...), { desc = desc })
end

-- Adjust LHS and description to your liking
map("<Leader>fr", "Select recent (cwd)", false, 1)
map("<Leader>fR", "Select recent (all)", true, 1)
map("<Leader>fa", "Select frecent (cwd)", false, 0.5)
map("<Leader>fA", "Select frecent (all)", true, 0.5)
map("<Leader>vf", "Select frequent (all)", true, 0)
map("<Leader>vF", "Select frequent (cwd)", false, 0)

keymap("n", "<leader>fm", function()
	require("mini.files").open(vim.api.nvim_buf_get_name(0), true)
end, { desc = "Open mini.files (Directory of Current File)" })
keymap("n", "<leader>fM", function()
	require("mini.files").open(vim.uv.cwd(), true)
end, { desc = "Open mini.files (cwd)" })
