require("plugins")
require("config.options")
require("config.keymaps")
require("config.autocmds")

-- plugins
require("plugins.mason")
require("plugins.fzf")
require("plugins.gitsigns")
require("plugins.mini")
require("plugins.lualine")
require("plugins.conform")
require("plugins.treesitter")
require("plugins.lsp")

local theme_path = vim.fn.stdpath("config") .. "/theme.lua"
if vim.fn.filereadable(theme_path) == 1 then
  dofile(theme_path)
end
