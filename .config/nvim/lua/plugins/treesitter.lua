vim.cmd.packadd("nvim-treesitter")

local parsers = {
	"bash",
	"css",
	"dockerfile",
	"go",
	"html",
	"http",
	"javascript",
	"json",
	"lua",
	"ron",
	"rust",
	"tsx",
	"typescript",
	"qmljs",
}

vim.api.nvim_create_autocmd("FileType", {
	pattern = parsers,
	callback = function()
		pcall(vim.treesitter.start)
	end,
})

local installed = require("nvim-treesitter.config").get_installed()
local to_install = vim.iter(parsers)
	:filter(function(p)
		return not vim.tbl_contains(installed, p)
	end)
	:totable()

if #to_install > 0 then
	vim.schedule(function()
		require("nvim-treesitter").install(to_install)
	end)
end
