-- Material 3 stylesheet. Seeds Theme from themeagen's saved palette so the
-- stylesheet gets the last generated colors before themeagen connects.
local saved = riced.file({ path = "data/theme/themeagen.json" }).data
local colors = saved.colors
---@type riced.ThemeagenPalette
Theme = (colors and colors[saved.mode]) or {}

return require("components.style.material")
