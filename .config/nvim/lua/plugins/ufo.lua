require("async")
require("ufo")

vim.keymap.set("n", "zR", require("ufo").openAllFolds)
vim.keymap.set("n", "zM", require("ufo").closeAllFolds)
require("ufo").setup({
	provider_selector = function(bufnr, filetype, buftype)
		if filetype == "qml" then
			return { "indent" }
		end
		return { "treesitter", "indent" }
	end,
})
