require("mini.animate").setup()
require("mini.ai").setup()
require("mini.completion").setup()
require("mini.files").setup()
require("mini.icons").setup()
require("mini.indentscope").setup()
require("mini.statusline").setup()
require("mini.sessions").setup()
require("mini.starter").setup()
require("mini.tabline").setup()
require("mini.visits").setup()
require("mini.pairs").setup()
require("mini.pick").setup({
	options = { show_icons = true },
	window = {
		config = function()
			local height = math.floor(0.618 * vim.o.lines)
			local width = math.floor(0.618 * vim.o.columns)
			return {
				anchor = "NW",
				height = height,
				width = width,
				row = math.floor(0.5 * (vim.o.lines - height)),
				col = math.floor(0.5 * (vim.o.columns - width)),
			}
		end,
	},
})
