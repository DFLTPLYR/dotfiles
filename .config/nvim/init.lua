require("plugins")
require("config.options")
require("config.keymaps")
require("config.autocmds")

-- plugins
require("plugins.colorizer")
require("plugins.mason")
require("plugins.fzf")
require("plugins.gitsigns")
require("plugins.mini")
require("plugins.lualine")
require("plugins.conform")
require("plugins.mason-conform")
-- require("plugins.cmp")
require("plugins.treesitter")
require("plugins.ufo")
require("plugins.lsp")

local function source_matugen()
	local matugen_path = os.getenv("HOME") .. "/.config/nvim/theme.lua"

	local file, err = io.open(matugen_path, "r")
	if err ~= nil then
		vim.cmd("colorscheme base16-catppuccin-mocha")
		vim.print(
			"A matugen style file was not found, but that's okay! The colorscheme will dynamically change if matugen runs!"
		)
	else
		dofile(matugen_path)
		io.close(file)
	end
end

source_matugen()

local function auxiliary_function()
	vim.defer_fn(function()
		source_matugen()
		dofile(vim.fn.stdpath("config") .. "/lua/plugins/lualine.lua")
		vim.api.nvim_set_hl(0, "Comment", { italic = true })
	end, 100)
end

vim.api.nvim_create_autocmd("Signal", {
	pattern = "SIGUSR1",
	callback = auxiliary_function,
})
