require("mason-lspconfig").setup({
	ensure_installed = {
		"bashls",
		"gopls",
		"lua_ls",
		"texlab",
		"ts_ls",
		"rust_analyzer",
		"helm_ls",
		"html",
		"cssls",
		"pyright",
		"qmlls",
		"nixd",
	},
	automatic_installation = true,
})
