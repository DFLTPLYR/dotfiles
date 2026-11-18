iced.define("notification_motion", function()
	return {
		duration = 180,
		easing = "out",
		enter = { from = { x = 180, scale = 0.9 } },
		exit = { to = { x = 180, scale = 0.9 }, duration = 120, easing = "in" },
	}
end)
