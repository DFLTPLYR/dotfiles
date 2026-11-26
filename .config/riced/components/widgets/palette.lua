-- Swatches for the theme palette.

local card = require("components.widgets.card")

local PALETTE = { "primary", "secondary", "success", "warning", "danger", "background" }

local function swatch(name)
	local label = name == "background" and theme.text or theme.background
	return iced.container(iced.text(name, { size = 9, center = true, color = label }), {
		width = iced.Length.fill,
		height = 30,
		align_x = "center",
		align_y = "center",
		style = {
			background = theme[name],
			border = { color = iced.opacity(theme.text, 20), width = 1, radius = 4 },
		},
	})
end

local function palette(entry, width, height)
	local rows = {}
	for i = 1, #PALETTE, 2 do
		rows[#rows + 1] = iced.row({
			swatch(PALETTE[i]),
			swatch(PALETTE[i + 1] or PALETTE[i]),
		}, { spacing = 6, width = iced.Length.fill })
	end
	return card.card(entry, width, height, iced.column(rows, { spacing = 6, width = iced.Length.fill }))
end

return {
	id = "palette",
	label = "Palette",
	icon = "palette",
	width = 260,
	height = 200,
	view = palette,
}
