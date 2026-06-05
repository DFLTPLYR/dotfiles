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

local nvim_lsp = vim.lsp
nvim_lsp.config("nixd", {
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
nvim_lsp.enable("nixd")
