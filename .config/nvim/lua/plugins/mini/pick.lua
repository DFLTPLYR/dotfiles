local preview = (function()
	local config = { orientation = "vertical", ratio = 0.6 }
	local state = { win_id = nil, buf_id = nil, last_item = nil, is_hidden = false }
	local cache = { win_config = {} }
	local scroll_map = { up = "<C-b>", down = "<C-f>", left = "zH", right = "zL" }

	local function reset()
		state.win_id = nil
		state.buf_id = nil
		state.last_item = nil
		state.is_hidden = false
		cache.win_config = {}
	end

	local function has_win()
		return state.win_id ~= nil and vim.api.nvim_win_is_valid(state.win_id)
	end

	local function create_buf()
		state.buf_id = vim.api.nvim_create_buf(false, true)
		vim.api.nvim_buf_set_name(state.buf_id, "minipick://" .. state.buf_id .. "/preview")
		vim.bo[state.buf_id].bufhidden = "wipe"
		vim.bo[state.buf_id].matchpairs = ""
		vim.b[state.buf_id].minicursorword_disable = true
		vim.b[state.buf_id].miniindentscope_disable = true
	end

	local function create_win(win_config)
		win_config.style = "minimal"
		state.win_id = vim.api.nvim_open_win(state.buf_id, false, win_config)
		vim.wo[state.win_id].foldenable = false
		vim.wo[state.win_id].foldmethod = "manual"
		vim.wo[state.win_id].linebreak = true
		vim.wo[state.win_id].scrolloff = 0
		vim.wo[state.win_id].winhighlight = "NormalFloat:MiniPickNormal,FloatBorder:MiniPickBorder"
		vim.wo[state.win_id].wrap = true
	end

	local function close_buf()
		pcall(vim.api.nvim_buf_delete, state.buf_id, { force = true })
		state.buf_id = nil
	end

	local function close_win()
		if has_win() then
			pcall(vim.api.nvim_win_close, state.win_id, true)
		end
		state.win_id = nil
	end

	local function close()
		close_win()
		close_buf()
		state.last_item = nil
	end

	---@param item table | nil
	local function show_preview(item)
		if item ~= nil then
			local preview_func = MiniPick.get_picker_opts().source.preview
			pcall(preview_func, state.buf_id, item)
		else
			vim.api.nvim_buf_set_lines(state.buf_id, 0, -1, false, {})
		end
	end

	local function compute_border_size(border)
		local n = type(border) == "table" and #border or 0
		if n == 0 then
			return 2
		elseif config.orientation == "vertical" then
			return ((border[3 % n + 1] == "" and 0 or 1) + (border[7 % n + 1] == "" and 0 or 1))
		else
			return ((border[1 % n + 1] == "" and 0 or 1) + (border[5 % n + 1] == "" and 0 or 1))
		end
	end

	local function compute_layout(window_config, preview_config)
		local preview_ratio = config.ratio
		local border_size = compute_border_size(window_config.border)

		if config.orientation == "vertical" then
			local preview_size = math.floor(preview_ratio * (window_config.width + border_size))
			local preview_width = math.max(1, preview_size - border_size)
			local main_width = math.max(1, window_config.width - preview_width - border_size)
			window_config.width = main_width
			preview_config.width = preview_width
			preview_config.col = window_config.col + (main_width + border_size)
		else
			local preview_size = math.floor(preview_ratio * (window_config.height + border_size))
			local preview_height = math.max(1, preview_size - border_size)
			local main_height = math.max(1, window_config.height - preview_height - border_size)
			window_config.height = main_height
			preview_config.height = preview_height
			if window_config.anchor == "SW" then
				window_config.row = window_config.row - (preview_height + border_size)
			else
				preview_config.row = window_config.row + (main_height + border_size)
			end
		end
	end

	local function setup(opts)
		config = vim.tbl_deep_extend("force", config, opts or {})
	end

	local function scroll(direction)
		if not has_win() then
			return
		end
		local keys = vim.api.nvim_replace_termcodes(scroll_map[direction], true, true, true)
		vim.api.nvim_win_call(state.win_id, function()
			vim.cmd("normal! " .. keys)
		end)
	end

	local function cache_win_config()
		local picker_state = MiniPick.get_picker_state()
		if not (picker_state.windows and picker_state.windows.main) then
			return
		end
		local window_config = vim.api.nvim_win_get_config(picker_state.windows.main)
		local keys = { "anchor", "border", "col", "height", "relative", "row", "width", "zindex" }
		for _, key in ipairs(keys) do
			cache.win_config[key] = window_config[key]
		end
	end

	local function update()
		if state.is_hidden then
			close()
			return
		end

		local picker_state = MiniPick.get_picker_state()
		if not (picker_state.windows and picker_state.windows.main) then
			return
		end

		local window_config = vim.deepcopy(cache.win_config)
		local preview_config = vim.deepcopy(cache.win_config)
		compute_layout(window_config, preview_config)

		vim.api.nvim_win_set_config(picker_state.windows.main, window_config)

		if not has_win() then
			create_buf()
			create_win(preview_config)
		else
			vim.api.nvim_win_set_config(state.win_id, preview_config)
		end

		local current_item = MiniPick.get_picker_matches().current
		if current_item ~= state.last_item then
			state.last_item = current_item
			create_buf()
			vim.api.nvim_win_set_buf(state.win_id, state.buf_id)
			show_preview(current_item)
		end
	end

	local function toggle()
		MiniPick.refresh()
		state.is_hidden = not state.is_hidden
		update()
	end

	local function stop()
		close()
		reset()
	end

	-- Update preview on picker refresh
	local mini_pick = require("mini.pick")
	local mini_pick_refresh = mini_pick.refresh
	mini_pick.refresh = function()
		mini_pick_refresh()
		if mini_pick.is_picker_active() then
			cache_win_config()
			vim.schedule(update)
		end
	end

	return {
		setup = setup,
		scroll = scroll,
		cache_win_config = cache_win_config,
		update = update,
		toggle = toggle,
		stop = stop,
	}
end)()

local group = vim.api.nvim_create_augroup("UserMiniPick", { clear = true })

vim.api.nvim_create_autocmd("User", {
	pattern = "MiniPickStart",
	group = group,
	callback = function()
		preview.cache_win_config()
		preview.update()
	end,
})

vim.api.nvim_create_autocmd("User", {
	pattern = "MiniPickMatch",
	group = group,
	callback = function()
		vim.schedule(preview.update)
	end,
})

vim.api.nvim_create_autocmd("User", {
	pattern = "MiniPickStop",
	group = group,
	callback = preview.stop,
})

---@param keys string
local function feedkeys(keys)
	keys = vim.api.nvim_replace_termcodes(keys, true, true, true)
	vim.api.nvim_feedkeys(keys, "n", true)
end

require("mini.pick").setup({
	mappings = {
		move_down_arrow = {
			char = "<Down>",
			func = function()
				feedkeys("<C-n>")
				vim.schedule(preview.update)
			end,
		},
		move_up_arrow = {
			char = "<Up>",
			func = function()
				feedkeys("<C-p>")
				vim.schedule(preview.update)
			end,
		},
		scroll_side_preview_down = {
			char = "<S-Down>",
			func = function()
				preview.scroll("down")
			end,
		},
		scroll_side_preview_up = {
			char = "<S-Up>",
			func = function()
				preview.scroll("up")
			end,
		},
		toggle_preview = "",
		toggle_side_preview = { char = "<Tab>", func = preview.toggle },
	},
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
