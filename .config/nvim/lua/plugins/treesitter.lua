vim.cmd.packadd("nvim-treesitter")

require("nvim-treesitter").setup()

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
