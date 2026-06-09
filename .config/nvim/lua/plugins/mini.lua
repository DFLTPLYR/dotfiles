require("mini.animate").setup()
require("mini.ai").setup()
require("mini.completion").setup()
require("mini.diff").setup()
require("mini.files").setup()
require("mini.icons").setup()
require("mini.indentscope").setup()
require("mini.statusline").setup()
require("mini.starter").setup()
require("mini.tabline").setup()
require("mini.visits").setup()
require("mini.pairs").setup()

require("mini.sessions").setup({
	autoread = false,
	autowrite = true,
	directory = vim.fn.stdpath("cache") .. "/sessions",
	file = "Session.vim",
	force = { read = false, write = true, delete = false },
	hooks = {
		pre = { read = nil, write = nil, delete = nil },
		post = { read = nil, write = nil, delete = nil },
	},
	verbose = { read = false, write = true, delete = true },
})
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
