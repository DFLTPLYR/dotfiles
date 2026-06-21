-- require("lspconfig")

vim.lsp.config("*", {})

vim.lsp.config("qmlls", {
	cmd = { "/etc/profiles/per-user/dfltplyr/bin/qmlls" },
	filetypes = { "qml" },
	root_markers = { "shell.qml", ".qmlls.ini", ".git" },
})

vim.lsp.enable("qmlls")

vim.lsp.enable({
	"bashls",
	"gopls",
	"lua_ls",
	"texlab",
	"ts_ls",
	"helm_ls",
	"html",
	"cssls",
	"pyright",
	"rust_analyzer",
	"vue_ls",
	"qmlls",
})

vim.diagnostic.config({ virtual_text = true })
local flake = "(builtins.getFlake (toString ./.))"

vim.g.lazyvim_php_lsp = "intelephense"

vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
	pattern = "*.vue",
	command = "setfiletype vue",
})

vim.lsp.config("nixd", {
	cmd = { "nixd" },
	filetypes = { "nix" },
	root_markers = { "flake.nix", ".git" },
	settings = {
		nixd = {
			nixpkgs = {
				expr = ("import %s.inputs.nixpkgs { }"):format(flake),
			},
			formatting = {
				command = { "alejandra" },
			},
			options = {
				nixos = {
					expr = ("%s.nixosConfigurations.nixosBtw.options"):format(flake),
				},
				home_manager = {
					expr = ("%s.nixosConfigurations.nixosBtw.options.home-manager.users.dfltplyr"):format(flake),
				},
			},
		},
	},
})
vim.lsp.enable("nixd")
