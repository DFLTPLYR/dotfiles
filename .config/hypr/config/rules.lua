local rule = hl.window_rule
rule({
	name = "Discord",
	match = {
		class = "vesktop",
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
	name = "Youtube",
	match = {
		class = "FFPWA-01KT3AH4H1SAQJW0Z0GS9K6ZWS",
	},
	opacity = "1 override 1 override 1 override",
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
		class = "cs2",
	},
	monitor = "DP-1",
	content = "game",
	fullscreen = true,
	maximize = true,
	fullscreen_state = 3,
})

rule({
	name = "CS2",
	match = {
		class = "steam_app_1422450",
	},
	monitor = "DP-1",
	content = "game",
	fullscreen = true,
	maximize = true,
	fullscreen_state = 3,
})

rule({
	name = "Kitty",
	match = {
		class = "kitty",
		initial_class = "kitty",
	},
	suppress_event = "maximize",
})
