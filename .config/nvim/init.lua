-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")

-- Source matugen colors on startup
local function source_matugen()
  local matugen_path = vim.fn.expand("~/.config/nvim/generated.lua")
  if vim.fn.filereadable(matugen_path) == 1 then
    dofile(matugen_path)
  else
    vim.cmd("colorscheme default")
  end
end
-- Hot-reload on matugen update
vim.api.nvim_create_autocmd("Signal", {
  pattern = "SIGUSR1",
  callback = source_matugen,
})
source_matugen()
