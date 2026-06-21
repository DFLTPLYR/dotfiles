require("mason-lspconfig").setup({
	ensure_installed = {
		"bashls",
		"lua_ls",
		"texlab",
		"ts_ls",
		"rust_analyzer",
		"helm_ls",
		"html",
		"cssls",
		"pyright",
	},
	automatic_installation = true,
})
