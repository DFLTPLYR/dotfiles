local autocmd = vim.api.nvim_create_autocmd
local augroup = vim.api.nvim_create_augroup

local highlight_group = augroup("YankHighlight", { clear = true })
autocmd("TextYankPost", {
	pattern = "*",
	callback = function()
		vim.highlight.on_yank({ timeout = 170 })
	end,
	group = highlight_group,
})

autocmd("BufWritePost", {
	pattern = "*.lua",
	callback = function()
		if vim.fn.expand("%:p"):find(vim.fn.stdpath("config"), 1, true) then
			vim.cmd("source %")
		end
	end,
})

autocmd({ "BufRead", "BufNewFile" }, {
	pattern = "*.ron",
	callback = function()
		vim.bo.filetype = "ron"
	end,
})

autocmd("LspAttach", {
	callback = function(ev)
		local client = vim.lsp.get_client_by_id(ev.data.client_id)
		local bufnr = ev.buf
		local opts = {
			noremap = true,
			silent = true,
		}
		vim.api.nvim_buf_set_keymap(bufnr, "n", "gD", "<cmd>lua vim.lsp.buf.declaration()<CR>", opts)
		vim.api.nvim_buf_set_keymap(bufnr, "n", "gd", "<cmd>lua vim.lsp.buf.definition()<CR>", opts)
		vim.api.nvim_buf_set_keymap(bufnr, "n", "K", "<cmd>lua vim.lsp.buf.hover()<CR>", opts)
		vim.api.nvim_buf_set_keymap(bufnr, "n", "<C-k>", "<cmd>lua vim.lsp.buf.code_action()<CR>", opts)
		vim.api.nvim_buf_set_keymap(bufnr, "v", "<C-k>", "<cmd>lua vim.lsp.buf.range_code_action()<CR>", opts)
		vim.api.nvim_buf_set_keymap(bufnr, "n", "gi", "<cmd>lua vim.lsp.buf.implementation()<CR>", opts)
		-- vim.api.nvim_buf_set_keymap(bufnr, "n", "<leader>s", "<cmd>lua vim.lsp.buf.signature_help()<CR>", opts)
		-- vim.api.nvim_buf_set_keymap(bufnr, "n", "<leader>lr", "<cmd>lua vim.lsp.buf.rename()<CR>", opts)
		vim.api.nvim_buf_set_keymap(bufnr, "n", "gr", "<cmd>lua vim.lsp.buf.references()<CR>", opts)
		-- vim.api.nvim_buf_set_keymap(bufnr, "n", "<leader>f", "<cmd>lua vim.diagnostic.open_float()<CR>", opts)
		vim.api.nvim_buf_set_keymap(
			bufnr,
			"n",
			"[d",
			'<cmd>lua vim.diagnostic.goto_prev({ border = "single" })<CR>',
			opts
		)
		vim.api.nvim_buf_set_keymap(
			bufnr,
			"n",
			"]d",
			'<cmd>lua vim.diagnostic.goto_next({ border = "single" })<CR>',
			opts
		)
		vim.lsp.document_color.enable(false, { bufnr = ev.buf })
	end,
})

-- Window width based on the offset from the center, i.e. center window
-- is 60, then next over is 20, then the rest are 10.
-- Can use more resolution if you want like { 60, 20, 20, 10, 5 }
local widths = { 60, 20, 10 }

local ensure_center_layout = function(ev)
	local state = MiniFiles.get_explorer_state()
	if state == nil then
		return
	end

	-- Compute "depth offset" - how many windows are between this and focused
	local path_this = vim.api.nvim_buf_get_name(ev.data.buf_id):match("^minifiles://%d+/(.*)$")
	local depth_this
	for i, path in ipairs(state.branch) do
		if path == path_this then
			depth_this = i
		end
	end
	if depth_this == nil then
		return
	end
	local depth_offset = depth_this - state.depth_focus

	-- Adjust config of this event's window
	local i = math.abs(depth_offset) + 1
	local win_config = vim.api.nvim_win_get_config(ev.data.win_id)
	win_config.width = i <= #widths and widths[i] or widths[#widths]

	win_config.col = math.floor(0.5 * (vim.o.columns - widths[1]))
	for j = 1, math.abs(depth_offset) do
		local sign = depth_offset == 0 and 0 or (depth_offset > 0 and 1 or -1)
		-- widths[j+1] for the negative case because we don't want to add the center window's width
		local prev_win_width = (sign == -1 and widths[j + 1]) or widths[j] or widths[#widths]
		-- Add an extra +2 each step to account for the border width
		win_config.col = win_config.col + sign * (prev_win_width + 2)
	end

	win_config.height = depth_offset == 0 and 25 or 20
	win_config.row = math.floor(0.5 * (vim.o.lines - win_config.height))
	win_config.border = { "🭽", "▔", "🭾", "▕", "🭿", "▁", "🭼", "▏" }
	vim.api.nvim_win_set_config(ev.data.win_id, win_config)
end

autocmd("User", { pattern = "MiniFilesWindowUpdate", callback = ensure_center_layout })
