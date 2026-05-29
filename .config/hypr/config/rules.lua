local rule = hl.window_rule
rule({
	name = "Discord",
	match = {
		class = "discord",
	},
	monitor = "DP-2",
})

rule({
	name = "Telegram",
	match = {
		class = "org.telegram.desktop",
	},
	monitor = "DP-2",
})

rule({
	name = "Steam",
	match = {
		class = "steam",
	},
	monitor = "DP-2",
})

rule({
	name = "Deadlock",
	match = {
		class = "steam_app_1422450",
		fullscreen_state_internal = 3,
		fullscreen_state_client = 3,
	},
	size = { "(monitor_w*1)", "(monitor_h*1)" },
	monitor = "DP-1",
	content = "game",
	fullscreen = true,
	maximize = true,
	fullscreen_state = 3,
})
