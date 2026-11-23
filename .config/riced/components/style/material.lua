-- Material 3-inspired theme.
-- Opt in from shell.lua:
--   riced.stylesheet = require("components.style.material")
-- or return it from components/style/stylesheet.lua.
-- The existing button.lua / text.lua / container.lua are left untouched.

local saved = riced.file({ path = "data/theme/themeagen.json" }).data
local colors = saved and saved.colors
local palette = Theme or (colors and saved.mode and colors[saved.mode]) or {}

local function role(name, fallback)
	return palette[name] or fallback
end

local transparent = "#00000000"
local surface = role("surface", theme and theme.background or "#1a1111")
local onsurface = role("onsurface", theme and theme.text or "#f0dede")
local surface_low = role("surface_container_low", surface)
local surface_high = role("surface_container_high", surface)
local surface_highest = role("surface_container_highest", surface_high)
local primary = role("primary", theme and theme.primary or "#ffb3b4")
local onprimary = role("onprimary", theme and theme.background or "#561d21")
local primary_container = role("primary_container", primary)
local on_primary_container = role("on_primary_container", onprimary)
local secondary_container = role("secondary_container", surface_high)
local on_secondary_container = role("on_secondary_container", onsurface)
local outline = role("outline", "#a08c8c")
local outline_variant = role("outline_variant", outline)
local onsurfacevariant = role("onsurfacevariant", outline)
local shadow = role("shadow", "#000000")

local function shadow_at(y, blur)
	return { color = iced.opacity(shadow, 20), offset = { x = 0, y = y }, blur = blur }
end

local flat_shadow = { color = transparent, offset = { x = 0, y = 0 }, blur = 0 }

local function input_style(has_icon)
	local style = {
		background = surface_low,
		text_color = onsurface,
		placeholder = onsurfacevariant,
		selection = iced.opacity(primary, 40),
		border = { color = outline, width = 1, radius = 10 },
		hovered = { border = { color = onsurface, width = 1, radius = 10 } },
		focused = { border = { color = primary, width = 2, radius = 10 } },
		disabled = {
			background = surface_high,
			text_color = outline,
			border = { color = outline_variant, width = 1, radius = 10 },
		},
	}
	if has_icon then
		style.icon_color = onsurfacevariant
	end
	return style
end

local function slider_style()
	return {
		style = {
			rail = surface_highest,
			filled = primary,
			border = { color = outline_variant, width = 1, radius = 4 },
			handle = primary,
			handle_border = { color = onprimary, width = 2, radius = 999 },
			hovered = { handle = onprimary },
			active = { handle = primary_container, filled = primary_container },
			dragged = { handle = primary_container, filled = primary_container },
		},
	}
end

return iced.stylesheet({
	button = {
		default = {
			padding = 8,
			style = {
				background = secondary_container,
				text_color = on_secondary_container,
				border = { radius = 10 },
				shadow = shadow_at(1, 2),
				hovered = {
					background = surface_high,
					border = { color = outline_variant, width = 1, radius = 10 },
					shadow = shadow_at(2, 4),
				},
				pressed = {
					background = primary_container,
					text_color = on_primary_container,
					border = { color = primary, width = 1, radius = 10 },
					shadow = shadow_at(1, 1),
				},
				-- disabled = {
				-- 	background = surface,
				-- 	text_color = outline,
				-- 	border = { color = outline_variant, width = 1, radius = 10 },
				-- 	shadow = flat_shadow,
				-- },
			},
			transition = iced.transition("basic"),
		},
		workspaces = {
			height = 20,
			padding = 0,
			style = {
				text_color = onprimary,
				border = { color = outline_variant, width = 1 },
				hovered = {
					background = surface_high,
					border = { color = outline_variant, width = 1, radius = 5 },
					shadow = shadow_at(2, 4),
				},
			},
		},
		systemtray = {
			width = 24,
			height = iced.Length.fill,
			padding = 0,
			clip = false,
			style = {
				background = transparent,
				text_color = onsurface,
				border = { color = transparent, width = 0, radius = 0 },
				shadow = flat_shadow,
				hovered = {
					background = transparent,
					border = { color = transparent, width = 0, radius = 0 },
					shadow = flat_shadow,
				},
				pressed = {
					background = transparent,
					border = { color = transparent, width = 0, radius = 0 },
					shadow = flat_shadow,
				},
			},
		},
	},
	text = {
		default = {
			color = onsurface,
			size = 16,
			font = { family = "Iosevka NFP" },
		},
		navbar_middle = {
			color = onsurface,
			size = 16,
			font = { family = "Iosevka NFP", weight = "bold" },
		},
	},
	container = { default = {} },
	text_input = { default = { style = input_style(true) } },
	text_editor = { default = { style = input_style(false) } },
	combo_box = { default = { style = input_style(true) } },
	checkbox = {
		default = {
			style = {
				background = surface,
				text_color = onsurface,
				border = { color = outline, width = 1, radius = 4 },
				icon_color = onprimary,
				active = {
					background = primary,
					border = { color = primary, width = 1, radius = 4 },
				},
				hovered = { border = { color = onsurface, width = 1, radius = 4 } },
				disabled = {
					background = surface_high,
					text_color = outline,
					border = { color = outline_variant, width = 1, radius = 4 },
				},
			},
		},
	},
	radio = {
		default = {
			style = {
				background = surface,
				text_color = onsurface,
				border = { color = outline, width = 1, radius = 999 },
				dot_color = onprimary,
				active = {
					background = primary,
					border = { color = primary, width = 1, radius = 999 },
				},
				hovered = { border = { color = onsurface, width = 1, radius = 999 } },
			},
		},
	},
	toggler = {
		default = {
			style = {
				background = surface_high,
				text_color = onsurface,
				border = { color = outline, width = 1, radius = 999 },
				foreground = onsurfacevariant,
				active = {
					background = primary,
					border = { color = primary, width = 1, radius = 999 },
					foreground = onprimary,
				},
				hovered = { border = { color = onsurface, width = 1, radius = 999 } },
				disabled = {
					background = surface,
					foreground = outline,
					border = { color = outline_variant, width = 1, radius = 999 },
				},
			},
		},
	},
	slider = { default = slider_style() },
	vertical_slider = { default = slider_style() },
	scrollable = {
		default = {
			style = {
				background = transparent,
				border = { color = transparent, width = 0, radius = 0 },
				rail = surface_high,
				scroller = outline,
				active = { scroller = primary },
				hovered = { scroller = onsurface },
				dragged = { scroller = primary },
			},
		},
	},
	pick_list = {
		default = {
			style = {
				background = surface_low,
				text_color = onsurface,
				placeholder = onsurfacevariant,
				handle = onsurfacevariant,
				border = { color = outline, width = 1, radius = 10 },
				hovered = { border = { color = onsurface, width = 1, radius = 10 } },
				opened = { border = { color = primary, width = 2, radius = 10 } },
			},
		},
	},
	progress_bar = {
		default = {
			style = {
				background = surface_highest,
				bar = primary,
				border = { color = outline_variant, width = 1, radius = 4 },
			},
		},
	},
	rule = {
		default = {
			style = { color = outline_variant, radius = 1, snap = true },
		},
	},
	markdown = {
		default = {
			style = { link_color = primary, inline_code_color = onsurfacevariant },
		},
	},
})
