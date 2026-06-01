local nvlsp = require("nvchad.configs.lspconfig")
local servers = { "ts_ls", "pyright", "rust_analyzer" }

vim.g.lazyvim_php_lsp = "intelephense"
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
	pattern = "*.vue",
	command = "setfiletype vue",
})

for _, lsp in ipairs(servers) do
	vim.lsp.config[lsp] = {
		on_attach = nvlsp.on_attach,
		on_init = nvlsp.on_init,
		capabilities = nvlsp.capabilities,
	}
	vim.lsp.enable(lsp)
end

-- qmlls needs explicit cmd
vim.lsp.config.qmlls = {
	cmd = { "qmlls" },
	on_attach = nvlsp.on_attach,
	on_init = nvlsp.on_init,
	capabilities = nvlsp.capabilities,
}
vim.lsp.enable("qmlls")

-- formatters
require("conform").formatters.qmlformat = {
	command = "qmlformat",
	args = { "-i" },
	stdin = false,
}
require("conform").formatters.by_ft = require("conform").formatters.by_ft or {}
require("conform").formatters.by_ft.qml = { "qmlformat" }

-- keybinds
vim.keymap.set("i", "jj", "<ESC>", { desc = "exit insert mode" })
vim.keymap.set("v", "<A-l>", ">gv", { desc = "Indent right" })
vim.keymap.set("v", "<A-h>", "<gv", { desc = "Indent left" })
