vim.lsp.enable({
	"bashls",
	"gopls",
	"lua_ls",
	"texlab",
	"ts_ls",
	"rust-analyzer",
	"helm_ls",
	"vue-language-server",
})

vim.diagnostic.config({ virtual_text = true })
local flake = "(builtins.getFlake (toString ./.))"

vim.g.lazyvim_php_lsp = "intelephense"

vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
	pattern = "*.vue",
	command = "setfiletype vue",
})

for _, lsp in ipairs({ "html", "cssls", "ts_ls", "pyright", "rust_analyzer", "qmlls" }) do
	vim.lsp.enable(lsp)
end

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
