-- formatters

local options = {
	formatters_by_ft = {
		lua = { "stylua" },
		qml = { "qmlformat" },
		nix = { "alejandra" },
	},

	format_on_save = {
		timeout_ms = 500,
		lsp_fallback = true,
	},

	formatters = {
		qmlformat = {
			command = "qmlformat",
			args = { "-i" },
			stdin = false,
		},
	},
}

return options
