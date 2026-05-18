hl.window_rule({
	name = "Deadlock",
	match = { initial_class = "Deadlock" },
	fullscreen = true,
})

local monitor = hl.get_active_monitor() or hl.get_monitor_at_cursor()
local is_portrait = monitor and (monitor.transform % 2 == 1 or monitor.width < monitor.height)
local direction = is_portrait and "down" or "right"

hl.config({
	scrolling = {
		fullscreen_on_one_column = false,
		column_width = 0.9,
		direction = direction,
		focus_fit_method = 0,
	},
})


