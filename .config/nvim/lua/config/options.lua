local opt = vim.opt

opt.guicursor = "i:ver25"
opt.colorcolumn = "0"
opt.signcolumn = "yes:2"
opt.termguicolors = true
opt.ignorecase = true
opt.swapfile = false
opt.autoindent = true
opt.expandtab = true
opt.tabstop = 4
opt.softtabstop = 4
opt.shiftwidth = 4
opt.shiftround = true
opt.listchars = "tab:│ ,multispace:│  ,lead: ,trail: ,nbsp:+"
opt.fillchars = { eob = " " }
opt.list = true
opt.number = true
opt.relativenumber = true
opt.numberwidth = 2
opt.wrap = false
opt.cursorline = true
opt.scrolloff = 8
opt.clipboard = "unnamedplus"
opt.inccommand = "nosplit"
opt.undodir = os.getenv("HOME") .. "/.vim/undodir"
opt.undofile = true
opt.completeopt = { "menuone", "popup", "noinsert" }
opt.winborder = "rounded"
opt.hlsearch = false
vim.g.netrw_banner = false
vim.g.netrw_liststyle = 1
vim.g.netrw_sort_by = "size"

vim.cmd.filetype("plugin indent on")
