iced.define("basic", function()
	return {
		duration = 180,
		spring = "smooth",
		change = {
			duration = 180,
			props = {
				"background",
				"text_color",
				"border",
				"shadow",
				"hovered.background",
				"hovered.text_color",
				"hovered.border",
				"hovered.shadow",
				"pressed.background",
				"pressed.text_color",
				"pressed.border",
				"pressed.shadow",
			},
		},
	}
end)
