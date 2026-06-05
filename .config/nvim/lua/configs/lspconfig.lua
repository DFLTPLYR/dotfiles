local nvlsp = require("nvchad.configs.lspconfig")

vim.g.lazyvim_php_lsp = "intelephense"
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
	pattern = "*.vue",
	command = "setfiletype vue",
})

local servers = { "html", "cssls", "ts_ls", "pyright", "rust_analyzer" }

for _, lsp in ipairs(servers) do
	vim.lsp.config(lsp, {
		on_attach = nvlsp.on_attach,
		on_init = nvlsp.on_init,
		capabilities = nvlsp.capabilities,
	})
	vim.lsp.enable(lsp)
end

vim.lsp.config("qmlls", {
	cmd = { "qmlls" },
	on_attach = nvlsp.on_attach,
	on_init = nvlsp.on_init,
	capabilities = nvlsp.capabilities,
})
vim.lsp.enable("qmlls")

vim.lsp.config("nixd", {
	cmd = { "nixd" },
	filetypes = { "nix" },
	root_markers = { "flake.nix", ".git" },
	settings = {
		nixd = {
			nixpkgs = {
				expr = "import (builtins.getFlake (toString ./.)).inputs.nixpkgs { }",
			},
			formatting = {
				command = { "alejandra" },
			},
			options = {
				nixos = {
					expr = "(builtins.getFlake (toString ./.)).nixosConfigurations.nixosBtw.options",
				},
				home_manager = {
					expr = "(builtins.getFlake (toString ./.)).nixosConfigurations.nixosBtw.options.home-manager.users.dfltplyr",
				},
			},
		},
	},
})
vim.lsp.enable("nixd")
