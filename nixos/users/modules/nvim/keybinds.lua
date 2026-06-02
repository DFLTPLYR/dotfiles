-- keybinds
vim.schedule(function()
	local map = vim.keymap.set
	-- Additional Keybinds
	map("i", "jj", "<ESC>", { desc = "exit insert mode" })
	map({"v", "n"}, "<A-l>", ">gv", { desc = "Indent right" })
	map({"v", "n"}, "<A-h>", "<gv", { desc = "Indent left" })
	map("n", "<A-j>", "<cmd>m .+1<CR>==", { desc = "Move line down" })
	map("v", "<A-j>", ":m '>+1<CR>gv=gv", { desc = "Move selection down" })
	map("n", "<A-k>", "<cmd>m .-2<CR>==", { desc = "Move line up" })
	map("v", "<A-k>", ":m '<-2<CR>gv=gv", { desc = "Move selection up" })

	-- Removed Keybinds
	local nomap = vim.keymap.del
	nomap("n", "<leader>h")
	nomap("n", "<leader>v")
	nomap({ "n", "t" }, "<A-h>")
	nomap({ "n", "t" }, "<A-v>")
end)
