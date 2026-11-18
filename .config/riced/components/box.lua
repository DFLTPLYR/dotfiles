local function box(content)
	return iced.container(content, {
		padding = 0,
		style = {
			text_color = theme.text,
			background = iced.opacity(theme.background, 80),
			border = {
				color = theme.background,
				width = 1,
				radius = 2,
			},
			shadow = {
				color = iced.opacity(theme.background, 99),
				offset = { x = 2, y = 2 },
				blur = 2,
			},
		},
	})
end

return box
