local keymap = vim.keymap.set
local s = { silent = true }

vim.g.mapleader = " "

-- [[ Leader key (space) ]]
keymap("n", "<space>", "<Nop>")

-- [[ s - Search ]]
keymap("n", "s", "/")

-- [[ j/k - Smart line movement ]]
keymap("n", "j", function()
	return tonumber(vim.api.nvim_get_vvar("count")) > 0 and "j" or "gj"
end, { expr = true, silent = true })
keymap("n", "k", function()
	return tonumber(vim.api.nvim_get_vvar("count")) > 0 and "k" or "gk"
end, { expr = true, silent = true })

-- [[ Esc ]]
keymap({ "i", "n", "s" }, "<esc>", function()
	vim.cmd("noh")
	return "<esc>"
end, { expr = true, desc = "Escape and Clear hlsearch" })

-- [[ Ctrl ]]
keymap("n", "<C-d>", "<C-d>zz")
keymap("n", "<C-u>", "<C-u>zz")

-- [[ Alt ]]
keymap("v", "<A-l>", ">gv", { desc = "Indent right" })
keymap("v", "<A-h>", "<gv", { desc = "Indent left" })
keymap("n", "<A-j>", "<cmd>m .+1<CR>==", { desc = "Move line down" })
keymap("v", "<A-j>", ":m '>+1<CR>gv=gv", { desc = "Move selection down" })
keymap("n", "<A-k>", "<cmd>m .-2<CR>==", { desc = "Move line up" })
keymap("v", "<A-k>", ":m '<-2<CR>gv=gv", { desc = "Move selection up" })

-- [[ Shift ]]
keymap("n", "<S-t>", "<cmd>tabnew<CR>", s)
keymap("n", "<S-h>", "<cmd>bprevious<cr>", { desc = "Prev Buffer" })
keymap("n", "<S-l>", "<cmd>bnext<cr>", { desc = "Next Buffer" })

-- [[ g prefix - LSP goto ]]
local opts = { noremap = true, silent = true }
keymap("n", "gd", vim.lsp.buf.definition, vim.tbl_extend("force", opts, { desc = "Goto Definition" }))
keymap("n", "gD", vim.lsp.buf.declaration, vim.tbl_extend("force", opts, { desc = "Goto Declaration" }))
keymap("n", "gr", vim.lsp.buf.references, vim.tbl_extend("force", opts, { desc = "References", nowait = true }))
keymap("n", "gI", vim.lsp.buf.implementation, vim.tbl_extend("force", opts, { desc = "Goto Implementation" }))
keymap("n", "gy", vim.lsp.buf.type_definition, vim.tbl_extend("force", opts, { desc = "Goto Type Definition" }))

-- [[ f prefix ]]
keymap("n", "fd", function()
	require("mini.bufremove").delete()
	if #vim.api.nvim_list_bufs() == 0 then
		require("mini.starter").open()
	end
end, s)
keymap("n", "<leader>fD", function()
	local delete = require("mini.bufremove").delete
	for _, buf in ipairs(vim.api.nvim_list_bufs()) do
		if vim.bo[buf].buflisted then
			delete(buf)
		end
	end
	if #vim.api.nvim_list_bufs() == 0 then
		require("mini.starter").open()
	end
end, { desc = "Delete all buffers" })

-- [[ <leader> prefix ]]

-- <leader>cd - Change directory
keymap("n", "<leader>cd", '<cmd>lua vim.fn.chdir(vim.fn.expand("%:p:h"))<CR>')

-- <leader>e - Explore / Pick
keymap("n", "<leader>ee", "<cmd>Pick files<CR>", { desc = "Pick file in current directory" })

-- <leader>f - File operations
keymap("n", "<leader>fe", "<cmd>Pick buffers<CR>", { desc = "Pick available buffers" })
keymap("n", "<leader>ff", function()
	require("mini.pick").builtin.files()
end, { desc = "Find files" })
keymap("n", "<leader>fg", function()
	require("mini.pick").builtin.grep_live()
end, { desc = "Live grep" })
keymap("n", "<leader>fo", ":lua vim.lsp.buf.format()<CR>", s)

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

map("<Leader>fr", "Select recent (cwd)", false, 1)
map("<Leader>fR", "Select recent (all)", true, 1)
map("<Leader>fa", "Select frecent (cwd)", false, 0.5)
map("<Leader>fA", "Select frecent (all)", true, 0.5)

keymap("n", "<leader>fm", function()
	require("mini.files").open(vim.uv.cwd(), true)
end, { desc = "Open mini.files (cwd)" })

-- <leader>g - Git
keymap("n", "<leader>gs", "<cmd>Git<CR>", opts)
keymap("n", "<leader>gp", "<cmd>Git push<CR>", opts)

-- <leader>p - Paste (visual)
keymap("v", "<Leader>p", '"_dP')

-- <leader>q - Quit
keymap("n", "<Leader>q", "<cmd>q<CR>", s)

-- <leader>v - Visits (mini.visits)
map("<Leader>vf", "Select frequent (cwd)", false, 0)
map("<Leader>vF", "Select frequent (all)", true, 0)

-- <leader>w - Write
keymap("n", "<Leader>w", "<cmd>w!<CR>", s)

-- [[ Insert mode ]]
keymap("i", "jj", "<ESC>", { desc = "exit insert mode" })

-- [[ Visual / Select mode ]]
keymap("x", "y", [["+y]], s)
