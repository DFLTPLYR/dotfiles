local autocmd = vim.api.nvim_create_autocmd
local augroup = vim.api.nvim_create_augroup

local highlight_group = augroup("YankHighlight", { clear = true })
autocmd("TextYankPost", {
	pattern = "*",
	callback = function()
		vim.highlight.on_yank({ timeout = 170 })
	end,
	group = highlight_group,
})

autocmd("BufWritePost", {
	pattern = "*.lua",
	callback = function()
		if vim.fn.expand("%:p"):find(vim.fn.stdpath("config"), 1, true) then
			vim.cmd("source %")
		end
	end,
})
