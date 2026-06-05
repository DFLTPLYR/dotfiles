local nvlsp = require("nvchad.configs.lspconfig")
local flake = "(builtins.getFlake (toString ./.))"

-- PHP
vim.g.lazyvim_php_lsp = "intelephense"

-- Filetype detection
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
	pattern = "*.vue",
	command = "setfiletype vue",
})

-- Global defaults
vim.lsp.config("*", {
	on_attach = nvlsp.on_attach,
	on_init = nvlsp.on_init,
	capabilities = nvlsp.capabilities,
})

-- Simple LSP servers
for _, lsp in ipairs({ "html", "cssls", "ts_ls", "pyright", "rust_analyzer", "qmlls" }) do
	vim.lsp.enable(lsp)
end

-- nixd
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
