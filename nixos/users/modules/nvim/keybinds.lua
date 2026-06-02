-- keybinds
vim.schedule(function()
	local map = vim.keymap.set
	-- Additional Keybinds
	map("i", "jj", "<ESC>", { desc = "exit insert mode" })
	map("v", "<A-l>", ">gv", { desc = "Indent right" })
	map("v", "<A-h>", "<gv", { desc = "Indent left" })
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

  if require("nvconfig").ui.tabufline.enabled then
    map("n", "<leader>b", "<cmd>enew<CR>", { desc = "buffer new" })

    map("n", "<A-l>", function()
      require("nvchad.tabufline").next()
    end, { desc = "buffer goto next" })

    map("n", "<A-h>", function()
      require("nvchad.tabufline").prev()
    end, { desc = "buffer goto prev" })

    map("n", "<leader>x", function()
      require("nvchad.tabufline").close_buffer()
    end, { desc = "buffer close" })
  end
end)
