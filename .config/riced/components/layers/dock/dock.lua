local shell = {
	side = "bottom",
	height = 40,
}

function shell.view(props)
	local anchor_pos = {
		top = { "left", "right", "top" },
		bottom = { "left", "right", "bottom" },
		left = { "left", "top", "bottom" },
		right = { "right", "top", "bottom" },
	}
	local vertical = shell.side == "top" or shell.side == "bottom"
	local anchor_size = vertical and { width = iced.Length.fill, height = shell.height }
		or { width = shell.height, height = iced.Length.fill }

	return iced.layer(
		iced.container(iced.space(), {
			width = "fill",
			height = "fill",
			style = {
				background = iced.opacity(Theme.surface, 20),
				border = {
					radius = 8,
				},
			},
		}),
		{
			id = "dock",
			size = anchor_size,
			anchor = anchor_pos[shell.side],
			exclusive_zone = shell.height,
			blur_option = "none",
		}
	)
end

return shell
