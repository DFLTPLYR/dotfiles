-- formatters
require("conform").setup({
	format_on_save = {
		timeout_ms = 500,
		lsp_fallback = true,
	},
})
require("conform").formatters.qmlformat = {
	command = "qmlformat",
	args = { "-i" },
	stdin = false,
}
require("conform").formatters.by_ft = require("conform").formatters.by_ft or {}
require("conform").formatters.by_ft.qml = { "qmlformat" }
require("conform").formatters.by_ft.nix = { "alejandra" }
