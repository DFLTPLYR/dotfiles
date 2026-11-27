-- Theme picker: data/theme/*.json palettes plus the themeagen mode.

local settings = require("data.settings").file

local function quoted(value)
	return "'" .. value:gsub("'", "'\\''") .. "'"
end

local function load_palettes()
	local list = {}
	if not io.popen then
		return list
	end
	local state = riced.file({ path = "data/theme/themeagen.json" })
	local directory = state.path:match("^(.*)[/\\][^/\\]+$")
	if not directory then
		return list
	end
	local pipe = io.popen("ls -1 " .. quoted(directory) .. " 2>/dev/null")
	if not pipe then
		return list
	end
	for line in pipe:lines() do
		local name = line:match("^(.+)%.json$")
		if name and name ~= "themeagen" then
			local colors = riced.file({ path = directory .. "/" .. line }).data
			if type(colors) == "table" and type(colors.dark) == "table" and type(colors.light) == "table" then
				list[#list + 1] = { name = name, colors = colors }
			end
		end
	end
	pipe:close()
	table.sort(list, function(a, b)
		return a.name < b.name
	end)
	return list
end

local palettes = load_palettes()
local SWATCHES = { "surface", "primary", "secondary", "tertiary", "hover", "error" }

iced.define("theme", function()
	local page = {}

	function page:view(props)
		local themeagen = riced.plugins("themeagen")
		local mode = themeagen.mode or "dark"
		local selected = settings.data.theme
		-- Wallpaper-driven palettes are shown as the dynamic entry.
		if themeagen.source and themeagen.source.kind ~= "manual" then
			selected = "dynamic"
		end

		local function save(name)
			local data = settings.data
			data.theme = name
			settings.data = data
			local ok, err = settings:write()
			if not ok then
				log(err)
			end
		end

		local function set_mode(value)
			if not themeagen.alive or not themeagen.populate then
				return
			end
			themeagen.populate({ mode = value }, function(_, error)
				if error then
					log(error)
				end
			end)
		end

		local function set_theme(palette)
			if not themeagen.alive or not themeagen.populate then
				return
			end
			themeagen.populate({ colors = palette.colors, mode = themeagen.mode or "dark" }, function(result, error)
				if error then
					log(error)
					return
				end
				for _, message in ipairs(result.errors or {}) do
					log(message)
				end
				save(palette.name)
			end)
		end

		local function control_style(active)
			return {
				background = active and theme.primary or iced.opacity(theme.background, 60),
				text_color = active and theme.background or theme.text,
				border = {
					color = active and theme.success or theme.primary,
					width = active and 2 or 1,
					radius = 4,
				},
			}
		end

		local function mode_button(label, value)
			return iced.button(label, {
				width = 120,
				style = control_style(mode == value),
				on_press = function()
					set_mode(value)
				end,
			})
		end

		local function palette_button(palette)
			local colors = palette.colors[mode] or palette.colors.dark
			local swatches = {}
			for _, key in ipairs(SWATCHES) do
				swatches[#swatches + 1] = iced.container(iced.text(key), {
					width = iced.Length.fill,
					height = iced.Length.fill,
					align_x = "center",
					align_y = "center",
					style = {
						background = colors[key],
					},
				})
			end
			local active = palette.name == selected
			return iced.button(
				iced.column({
					iced.text(palette.name, {
						width = iced.Length.fill,
						center = true,
						size = 24,
						color = active and theme.background or theme.text,
					}),
					iced.column(swatches, {
						width = iced.Length.fill,
						height = iced.Length.fill,
						spacing = 2,
					}),
				}, {
					width = iced.Length.fill,
					height = iced.Length.fill,
					spacing = 4,
				}),
				{
					width = iced.Length.fill,
					height = iced.Length.fill,
					padding = 6,
					style = control_style(active),
					on_press = function()
						set_theme(palette)
					end,
				}
			)
		end

		local buttons = {}
		for _, palette in ipairs(palettes) do
			buttons[#buttons + 1] = palette_button(palette)
		end

		local children = {
			iced.text("Theme", {
				line_height = 2,
				font = { weight = "bold" },
			}),
			iced.row({
				mode_button("Dark", "dark"),
				mode_button("Light", "light"),
			}, { spacing = 8 }),
		}
		if #buttons > 0 then
			children[#children + 1] = iced.grid(buttons, { columns = 3, spacing = 8 })
		else
			children[#children + 1] = iced.text("no palettes found", {
				size = 12,
				color = theme.secondary,
			})
		end

		local content = iced.column(children, {
			width = iced.Length.fill,
			spacing = 8,
		})

		return iced.scrollable(content, {
			width = iced.Length.fill,
			height = iced.Length.fill,
		})
	end

	return page
end)
