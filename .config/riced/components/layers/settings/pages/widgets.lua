-- Desktop widget gallery: a masonry of live widget previews. Press one to drag
-- it onto the desktop; right-click a placed widget there to remove it.

local desktop = require("components.desktop_widgets")

local COLUMNS = 3
local CARD_WIDTH = 190
local SPACING = 8

local function preview_height(entry)
	return math.max(math.floor(CARD_WIDTH * entry.height / entry.width), 120)
end

local function card(entry)
	return iced.mouse_area(
		entry.view(entry, iced.Length.fill, preview_height(entry)),
		{ on_press = { event = "widgets:add", args = { id = entry.id } } }
	)
end

-- Shortest-column packing keeps each widget's aspect ratio.
local function masonry(entries)
	local columns, heights = {}, {}
	for i = 1, COLUMNS do
		columns[i] = {}
		heights[i] = 0
	end
	for _, entry in ipairs(entries) do
		local shortest = 1
		for i = 2, COLUMNS do
			if heights[i] < heights[shortest] then
				shortest = i
			end
		end
		columns[shortest][#columns[shortest] + 1] = card(entry)
		heights[shortest] = heights[shortest] + preview_height(entry) + SPACING
	end

	local columnsView = {}
	for i = 1, COLUMNS do
		columnsView[#columnsView + 1] = iced.column(columns[i], {
			width = iced.Length.fill,
			spacing = SPACING,
		})
	end
	return iced.row(columnsView, {
		width = iced.Length.fill,
		spacing = SPACING,
		align_y = "top",
	})
end

iced.define("widgets", function()
	local page = {}

	function page:view(props)
		return iced.scrollable(
			iced.column({
				iced.text("Desktop widgets", { size = 20, font = { weight = "bold" } }),
				iced.text("Press a widget to place it on the desktop. Right-click one there to remove it.", {
					size = 12,
					color = theme.secondary,
					wrap = "word_or_glyph",
				}),
				masonry(desktop.catalog),
				iced.rule(),
				iced.text(string.format("%d placed", #desktop.list()), {
					size = 12,
					color = theme.secondary,
				}),
			}, {
				width = iced.Length.fill,
				spacing = 10,
			}),
			{
				width = iced.Length.fill,
				height = iced.Length.fill,
			}
		)
	end

	return page
end)
