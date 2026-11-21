require("components.motion")

local Transparent = "#00000000"

-- The default/material/boxy variants are identical for now.
local function base()
	return {
		padding = 8,
		style = {
			background = Theme.surface,
			text_color = Theme.onsurface,
			hovered = {
				background = iced.opacity(Theme.primary, 80),
				border = { color = theme.secondary, width = 1, radius = 2 },
			},
			pressed = {
				background = theme.success,
			},
		},
		transition = iced.transition("basic"),
	}
end

return {
	default = base(),
	material = base(),
	boxy = base(),
	workspaces = {
		height = 20,
		style = {
			text_color = Theme.onprimary,
			border = {
				width = 1,
				color = Theme.outline,
			},
			shadow = {
				color = iced.opacity(Theme.shadow, 90),
				offset = { x = 2, y = 2 },
				blur = 4,
			},
			hovered = {
				text_color = Theme.onsurface,
				background = iced.opacity(theme.primary, 70),
				border = {
					width = 2,
					color = Theme.primary,
				},
				shadow = {
					color = iced.opacity(Theme.primary, 90),
					offset = { x = 2, y = 2 },
					blur = 4,
				},
			},
		},
		transition = iced.transition("basic"),
	},
	systemtray = {
		width = 24,
		height = iced.Length.fill,
		padding = 0,
		clip = false,
		style = {
			background = Transparent,
			hovered = {
				background = Transparent,
				border = { color = Transparent },
			},
			pressed = {
				background = Transparent,
			},
		},
	},
}
