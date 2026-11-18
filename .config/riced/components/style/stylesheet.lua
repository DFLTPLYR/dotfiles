Transparent = "#00000000"

-- Active stylesheet: "material" or "default" (button/text/container below).
local STYLE = "material"

-- themeagen connects after the shell loads; seed Theme from its saved palette
-- so the stylesheet gets the last generated colors instead of nil.
local saved = riced.file({ path = "data/theme/themeagen.json" }).data
local colors = saved.colors
---@type riced.ThemeagenPalette
Theme = (colors and colors[saved.mode]) or {}

if STYLE == "material" then
	return require("components.style.material")
end

return iced.stylesheet({
	button = require("components.style.button"),
	text = require("components.style.text"),
	container = require("components.style.container"),
})
