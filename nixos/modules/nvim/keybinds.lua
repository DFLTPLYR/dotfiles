-- keybinds
vim.schedule(function()
	local map = vim.keymap.set
	-- Additional Keybinds
	map("i", "jj", "<ESC>", { desc = "exit insert mode" })
	map("v", "<A-l>", ">gv", { desc = "Indent right" })
	map("v", "<A-h>", "<gv", { desc = "Indent left" })

	-- Removed Keybinds
	local nomap = vim.keymap.del
	nomap("n", "<leader>h")
	nomap("n", "<leader>v")
	nomap({ "n", "t" }, "<A-h>")
	nomap({ "n", "t" }, "<A-v>")
end)
