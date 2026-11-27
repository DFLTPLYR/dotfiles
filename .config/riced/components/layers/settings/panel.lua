local state = require("data.state")

local panel = {
	menu_open = false,
	page = 1,
}

local PANEL_WIDTH = 800
local PANEL_HEIGHT = 600

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
		{ label = "Widgets", page = 5, leaf = iced.widgets() },
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

	local content = iced.container(row, {
		width = iced.Length.fill,
		height = iced.Length.fill,
		padding = 12,
		style = {
			background = iced.opacity(theme.background, 50),
			-- border = { color = iced.opacity(theme.text, 20), width = 0, radius = 6 },
			shadow = { color = iced.opacity(theme.background, 90), offset = { x = 4, y = 4 }, blur = 12 },
		},
	})

	local stack = iced.stack({
		iced.mouse_area(
			iced.container(iced.space(), {
				width = iced.Length.fill,
				height = iced.Length.fill,
				style = {
					background = iced.opacity(theme.background, 45),
				},
			}),
			{ on_press = close }
		),
		-- Swallow clicks on the panel so they do not reach the backdrop.
		iced.container(iced.mouse_area(content, { on_press = "settings:noop" }), {
			width = iced.Length.fill,
			height = iced.Length.fill,
			align_x = "center",
			align_y = "center",
		}),
	}, {
		width = iced.Length.fill,
		height = iced.Length.fill,
	})
	return stack
end
function panel:view()
	return iced.layer(view(), {
		id = "settings",
		size = iced.Size(iced.Extent.fill, iced.Extent.fill),
		layer = iced.Layer.top,
		anchor = { "top", "bottom", "left", "right" },
		exclusive_zone = -1,
		keyboard_interactivity = iced.KeyboardInteractivity.exclusive,
		output_option = iced.Output.active,
		namespace = "riced-settings",
	})
end

return panel
