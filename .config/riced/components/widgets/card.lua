-- Shared chrome for desktop widget cards: layout, typography and the frame.

local lucide = require("extensions.lucide.lucide")

local GIB = 1024 * 1024 * 1024

local card = {}

-- Plain iced.icon keeps repeated widget instances from colliding on ids.
function card.icon(name, color)
	return lucide.icon(name, { size = 16, color = color or theme.primary }, iced.text(" ", { size = 16 }))
end

function card.clamp(value, low, high)
	return math.min(math.max(value, low), high)
end

function card.gib(value)
	return (value or 0) / GIB
end

function card.percent(value)
	return string.format("%.0f%%", value or 0)
end

function card.big(text, size)
	return iced.text(text, { size = size or 26, color = theme.text, font = { weight = "bold" } })
end

function card.note(text)
	return iced.text(text, { size = 11, color = theme.secondary, wrap = "word_or_glyph" })
end

function card.placeholder(text)
	return iced.text(text, { size = 12, color = theme.secondary, wrap = "word_or_glyph" })
end

function card.meter(value)
	return iced.progress_bar(nil, { value = card.clamp(value or 0, 0, 1), girth = 4, width = iced.Length.fill })
end

---@param entry table Widget metadata; supplies label and icon.
---@param width number
---@param height number
---@param content iced.Element|iced.Element[]
---@param icon_name? string Overrides the entry icon.
function card.card(entry, width, height, content, icon_name)
	if type(content) == "table" and type(content.kind) == "string" then
		content = { content }
	end
	local children = {
		iced.row({
			card.icon(icon_name or entry.icon),
			iced.text(entry.label, { size = 12, color = theme.secondary, font = { weight = "bold" } }),
			iced.container(iced.space(), { width = iced.Length.fill }),
		}, { width = iced.Length.fill, spacing = 6, align_y = "center" }),
	}
	for _, child in ipairs(content) do
		children[#children + 1] = child
	end
	return iced.container(
		iced.column(children, { width = iced.Length.fill, height = iced.Length.fill, spacing = 6 }),
		{
			width = width,
			height = height,
			padding = 10,
			clip = true,
			style = {
				background = iced.opacity(theme.background, 88),
				border = { color = iced.opacity(theme.text, 20), width = 1, radius = 8 },
				shadow = { color = iced.opacity(theme.background, 80), offset = { x = 2, y = 2 }, blur = 6 },
			},
		}
	)
end

return card
