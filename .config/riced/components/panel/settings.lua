local state = require("data.state")

local panel = {
	menu_open = false,
	page = 1,
}

local function close()
	state.close_settings()
end

local function spacer(props, content)
	return iced.container(content or iced.space(), props)
end
local function view()
	local pages = {
		{ label = "Info", page = 1, leaf = iced.info() },
		{ label = "Wallpaper", page = 2, leaf = iced.wallpaper() },
		{ label = "Outputs", page = 3, leaf = iced.outputs() },
		{ label = "Theme", page = 4, leaf = iced.theme() },
	}
	-- Derived from state: a local set in on_press dies with that view pass.
	local currentPage = (pages[panel.page] or pages[1]).leaf

	local nav = iced.list_view(pages, {
		id = "navigation",
		key = "page",
		direction = "vertical",
		width = iced.Length.fill,
		height = iced.Length.fill,
		padding = 8,
		spacing = 4,
		render = function(item, index)
			local selected = panel.page == item.page
			local label = iced.text(item.label, {
				center = true,
				wrap = "word_or_glyph",
				font = { family = "serif", weight = "bold", style = "italic", stretch = "condensed" },
			})
			return iced.button(label, {
				width = iced.Length.fill,
				height = 48,
				style = {
					background = selected and theme.primary or theme.background,
					text_color = selected and theme.background or theme.primary,
					border = {
						width = 4,
						color = selected and theme.success or theme.background,
						radius = selected and 4 or 2,
					},
				},
				transition = iced.transition("basic"),
				on_press = function()
					if panel.page == item.page then
						return
					end
					panel.page = item.page
				end,
			})
		end,
	})

	local header = iced.row({
		iced.text("Settings", { size = 20, color = theme.primary, font = { weight = "bold" } }),
		iced.container(iced.space(), { width = iced.Length.fill }),
	}, {
		width = iced.Length.fill,
		align_y = "center",
	})

	local row = iced.row({
		spacer({
			width = 180,
			height = iced.Length.fill,
		}, nav),
		spacer(
			{
				width = iced.Length.fill,
				height = iced.Length.fill,
			},
			iced.column({
				header,
				currentPage,
			}, {
				width = iced.Length.fill,
				height = iced.Length.fill,
				spacing = 12,
			})
		),
	}, {
		width = iced.Length.fill,
		height = iced.Length.fill,
		spacing = 8,
	})

	return iced.container(iced.stack({
		iced.container(iced.space(), {

			width = iced.Length.fill_portion(7),
			height = iced.Length.fill,
			style = {
				background = iced.opacity(theme.background, 80),
			},
		}),
		row,
	}, {
		width = iced.Length.fill,
		height = iced.Length.fill,
	}))
end
function panel:view()
	local content = view()

	return iced.window({
		id = "settings",
		title = "Settings",
		width = 800,
		height = 600,
		content = content,
	})
end

return panel
