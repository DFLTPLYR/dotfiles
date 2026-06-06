return {
	{
		"stevearc/conform.nvim",
		event = "BufWritePre", -- uncomment for format on save
		opts = require("configs.conform"),
	},
	{
		"nvim-mini/mini.pick",
		version = "*",
		cmd = "Pick",
		keys = {
			{ "<leader>ff", desc = "Find files" },
		},
		config = function()
			require("mini.pick").setup()
		end,
	},
	-- These are some examples, uncomment them if you want to see them work!
	{
		"neovim/nvim-lspconfig",
		config = function()
			require("configs.lspconfig")
		end,
	},

	-- test new blink
	-- { import = "nvchad.blink.lazyspec" },

	{
		"nvim-treesitter/nvim-treesitter",
		opts = {
			ensure_installed = {
				"vim",
				"lua",
				"vimdoc",
				"html",
				"css",
				"ron",
				"qml",
			},
		},
	},
}
