local header_art = [[
 ╭╮╭┬─╮╭─╮┬  ┬┬╭┬╮  ╭──╮╭───╮┬    ┬
 │││├┤ │ │╰┐┌╯││││  ├──╯  │  ╰┐╭╮┌╯
 ╯╰╯╰─╯╰─╯ ╰╯ ┴┴ ┴  ╰──╯  ┴   ╰╯╰╯
]]

require("mini.starter").setup({
	header = header_art,
})

require("mini.animate").setup({
	scroll = { enable = false },
})
require("mini.ai").setup()

-- cmp + luasnip handle completion and snippets instead
require("mini.diff").setup()
require("mini.splitjoin").setup()
require("mini.bufremove").setup()
require("mini.cursorword").setup()
require("mini.files").setup({
	windows = {
		preview = true,
		width_focus = 30,
		width_preview = 30,
	},
	options = {
		use_as_default_explorer = false,
	},
})

local show_dotfiles = true
local filter_show = function()
	return true
end
local filter_hide = function(fs_entry)
	return not vim.startswith(fs_entry.name, ".")
end
local toggle_dotfiles = function()
	show_dotfiles = not show_dotfiles
	local new_filter = show_dotfiles and filter_show or filter_hide
	require("mini.files").refresh({ content = { filter = new_filter } })
end

local map_split = function(buf_id, lhs, direction, close_on_file)
	local rhs = function()
		local new_target_window
		local cur_target_window = require("mini.files").get_explorer_state().target_window
		if cur_target_window ~= nil then
			vim.api.nvim_win_call(cur_target_window, function()
				vim.cmd("belowright " .. direction .. " split")
				new_target_window = vim.api.nvim_get_current_win()
			end)
			require("mini.files").set_target_window(new_target_window)
			require("mini.files").go_in({ close_on_file = close_on_file })
		end
	end
	local desc = "Open in " .. direction .. " split"
	if close_on_file then
		desc = desc .. " and close"
	end
	vim.keymap.set("n", lhs, rhs, { buffer = buf_id, desc = desc })
end

local files_set_cwd = function()
	local cur_entry_path = require("mini.files").get_fs_entry().path
	local cur_directory = vim.fs.dirname(cur_entry_path)
	if cur_directory ~= nil then
		vim.fn.chdir(cur_directory)
	end
end

vim.api.nvim_create_autocmd("User", {
	pattern = "MiniFilesBufferCreate",
	callback = function(args)
		local buf_id = args.data.buf_id
		vim.keymap.set("n", "g.", toggle_dotfiles, { buffer = buf_id, desc = "Toggle hidden files" })
		vim.keymap.set("n", "gc", files_set_cwd, { buffer = buf_id, desc = "Set cwd" })
		map_split(buf_id, "<C-w>s", "horizontal", false)
		map_split(buf_id, "<C-w>v", "vertical", false)
		map_split(buf_id, "<C-w>S", "horizontal", true)
		map_split(buf_id, "<C-w>V", "vertical", true)
	end,
})

require("mini.icons").setup()
require("mini.indentscope").setup()
require("mini.statusline").setup()
require("mini.tabline").setup()
require("mini.visits").setup()
require("mini.pairs").setup()

local session_dir = vim.fn.stdpath("cache") .. "/sessions"
local session_file = session_dir .. "/Session.vim"

require("mini.sessions").setup({
	autoread = vim.fn.filereadable(session_file) == 1,
	autowrite = true,
	directory = session_dir,
	file = "Session.vim",
	force = { read = false, write = true, delete = false },
	hooks = {
		pre = { read = nil, write = nil, delete = nil },
		post = { read = nil, write = nil, delete = nil },
	},
	verbose = { read = false, write = true, delete = true },
})

local MiniPick = require("mini.pick")
MiniPick.setup({
	options = { show_icons = true },
	window = {
		config = function()
			local height = math.floor(0.618 * vim.o.lines)
			local width = math.floor(0.618 * vim.o.columns)
			return {
				anchor = "NW",
				height = height,
				width = width,
				row = math.floor(0.5 * (vim.o.lines - height)),
				col = math.floor(0.5 * (vim.o.columns - width)),
			}
		end,
	},
})

-- Add dd mapping to close buffers in :Pick buffers
local wipeout_cur = function()
	local item = MiniPick.get_picker_matches().current
	if item then
		vim.api.nvim_buf_delete(item.bufnr, { force = false, unload = true })
		MiniPick.get_picker_matches().picker:close()
	end
end
local buffer_mappings = { delete = { char = "dd", func = wipeout_cur } }

local original = MiniPick.registry.buffers
MiniPick.registry.buffers = function(local_opts)
	return MiniPick.builtin.buffers(local_opts, { mappings = buffer_mappings })
end
