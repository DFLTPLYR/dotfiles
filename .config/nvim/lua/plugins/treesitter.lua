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

local filetypes = vim.list_extend({}, parsers)
table.insert(filetypes, "qml")

vim.api.nvim_create_autocmd("FileType", {
	pattern = filetypes,
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
