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
	},
	monitor = "DP-1",
	fullscreen = true,
	content = "game",
	maximize = true,
})
