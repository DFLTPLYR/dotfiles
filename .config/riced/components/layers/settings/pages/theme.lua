-- Theme picker: data/theme/*.json palettes plus the themeagen mode.

local settings = require("data.settings").file

local function quoted(value)
	return "'" .. value:gsub("'", "'\\''") .. "'"
end

local function palette_names()
	local names = {}
	if not io.popen then
		return names
	end
	local state = riced.file({ path = "data/theme/themeagen.json" })
	local directory = state.path:match("^(.*)[/\\][^/\\]+$")
	if not directory then
		return names
	end
	local pipe = io.popen("ls -1 " .. quoted(directory) .. " 2>/dev/null")
	if not pipe then
		return names
	end
	for line in pipe:lines() do
		local name = line:match("^(.+)%.json$")
		if name and name ~= "themeagen" then
			names[#names + 1] = name
		end
	end
	pipe:close()
	table.sort(names)
	return names
end

local names = palette_names()

iced.define("theme", function()
	local page = {}

	function page:view(props)
		local themeagen = riced.plugins("themeagen")
		local mode = themeagen.mode or "dark"
		local selected = themeagen.source and themeagen.source.kind == "manual"
			and settings.data.theme or nil

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

		local function set_theme(name)
			if not themeagen.alive or not themeagen.populate then
				return
			end
			local colors = riced.file({ path = "data/theme/" .. name .. ".json" }).data
			if type(colors) ~= "table" or type(colors.dark) ~= "table" or type(colors.light) ~= "table" then
				log("invalid theme: " .. name)
				return
			end
			themeagen.populate({ colors = colors, mode = themeagen.mode or "dark" }, function(result, error)
				if error then
					log(error)
					return
				end
				for _, message in ipairs(result.errors or {}) do
					log(message)
				end
				save(name)
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

		local palettes = {}
		for _, name in ipairs(names) do
			palettes[#palettes + 1] = iced.button(name, {
				style = control_style(name == selected),
				on_press = function()
					set_theme(name)
				end,
			})
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
		if #palettes > 0 then
			children[#children + 1] = iced.grid(palettes, { columns = 3, spacing = 8 })
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
