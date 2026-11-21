-- Desktop widgets: example cards placed on the wallpaper layer.
-- Left-press to drag (the background layer promotes to overlay), right-press to
-- remove. The settings Widgets page adds new ones with "widgets:add".

local settings = require("data.settings").file
local lucide = require("extensions.lucide.lucide")
local openmeteo = require("extensions.openmeteo.openmeteo")

local WEATHER_LAT, WEATHER_LON = 14.082809573743582, 120.83566060057112
openmeteo.configure(WEATHER_LAT, WEATHER_LON)

local GIB = 1024 * 1024 * 1024

local function system()
	return riced.plugins("system")
end

local function icon(name, color)
	-- Plain iced.icon keeps repeated widget instances from colliding on ids.
	return lucide.icon(name, { size = 16, color = color or theme.primary }, iced.text(" ", { size = 16 }))
end

local function clamp(value, low, high)
	return math.min(math.max(value, low), high)
end

local function gib(value)
	return (value or 0) / GIB
end

local function percent(value)
	return string.format("%.0f%%", value or 0)
end

local function big(text, size)
	return iced.text(text, { size = size or 26, color = theme.text, font = { weight = "bold" } })
end

local function note(text)
	return iced.text(text, { size = 11, color = theme.secondary, wrap = "word_or_glyph" })
end

local function placeholder(text)
	return iced.text(text, { size = 12, color = theme.secondary, wrap = "word_or_glyph" })
end

local function meter(value)
	return iced.progress_bar(nil, { value = clamp(value or 0, 0, 1), girth = 4, width = iced.Length.fill })
end

local function card(entry, width, height, content, icon_name)
	if type(content) == "table" and type(content.kind) == "string" then
		content = { content }
	end
	local children = {
		iced.row({
			icon(icon_name or entry.icon),
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

local function cpu(entry, width, height)
	local store = system()
	local data = store and store.cpu
	if type(data) ~= "table" then
		return card(entry, width, height, placeholder("CPU unavailable"))
	end
	local usage = data.usage
	return card(entry, width, height, {
		big(usage and percent(usage) or "--"),
		note(string.format("%.2f GHz · %d cores", (data.frequency or 0) / 1000, data.cores or 0)),
		meter((usage or 0) / 100),
	})
end

local function gpu(entry, width, height)
	local store = system()
	local data = store and store.gpus and store.gpus[1]
	if type(data) ~= "table" then
		return card(entry, width, height, placeholder("GPU unavailable"))
	end
	local detail = {}
	if data.temp then
		detail[#detail + 1] = string.format("%.0f°C", data.temp)
	end
	if data.vram_used and data.vram_total then
		detail[#detail + 1] = string.format("%.1f / %.1f GiB", gib(data.vram_used), gib(data.vram_total))
	end
	return card(entry, width, height, {
		big(data.busy and percent(data.busy) or "--"),
		note(table.concat(detail, " · ")),
		meter((data.busy or 0) / 100),
	})
end

local function ram(entry, width, height)
	local store = system()
	local data = store and store.memory
	if type(data) ~= "table" or not data.total or data.total <= 0 then
		return card(entry, width, height, placeholder("Memory unavailable"))
	end
	local ratio = (data.used or 0) / data.total
	return card(entry, width, height, {
		big(string.format("%.1f / %.1f GiB", gib(data.used), gib(data.total)), 20),
		note(string.format("%.0f%% used", ratio * 100)),
		meter(ratio),
	})
end

local function weather_icon(current)
	local code = current.weather_code or 0
	if code == 0 then
		return current.is_day == 0 and "moon" or "sun"
	elseif code <= 3 then
		return "cloud-sun"
	elseif code == 45 or code == 48 then
		return "cloud-fog"
	elseif code >= 51 and code <= 67 then
		return "cloud-rain"
	elseif code >= 71 and code <= 77 then
		return "cloud-snow"
	elseif code >= 80 and code <= 82 then
		return "cloud-rain-wind"
	elseif code >= 85 and code <= 86 then
		return "cloud-snow"
	elseif code >= 95 then
		return "cloud-lightning"
	end
	return "cloud"
end

local function weather(entry, width, height)
	local ext = openmeteo.plugin
	local current = ext.current or {}
	local temp = current.temperature_2m
	if not ext.alive then
		return card(entry, width, height, placeholder("Weather offline"), "cloud")
	end
	if type(temp) ~= "number" then
		return card(entry, width, height, placeholder(ext.error and "Weather unavailable" or "Loading weather…"), "cloud")
	end
	local detail = {}
	if current.relative_humidity_2m then
		detail[#detail + 1] = string.format("H %.0f%%", current.relative_humidity_2m)
	end
	if current.wind_speed_10m then
		detail[#detail + 1] = string.format("W %.0f km/h", current.wind_speed_10m)
	end
	return card(entry, width, height, {
		big(string.format("%.1f°C", temp)),
		note(table.concat(detail, " · ")),
	}, weather_icon(current))
end

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
	return card(entry, width, height, iced.column(rows, { spacing = 6, width = iced.Length.fill }))
end

local catalog = {
	{ id = "cpu", label = "CPU", icon = "cpu", width = 200, height = 150, view = cpu },
	{ id = "gpu", label = "GPU", icon = "gpu", width = 300, height = 140, view = gpu },
	{ id = "ram", label = "RAM", icon = "memory-stick", width = 160, height = 180, view = ram },
	{ id = "weather", label = "Weather", icon = "cloud-sun", width = 240, height = 120, view = weather },
	{ id = "palette", label = "Palette", icon = "palette", width = 260, height = 200, view = palette },
}

local presets = {}
for _, entry in ipairs(catalog) do
	presets[entry.id] = entry
end

local desktop = {
	catalog = catalog,
	drag = nil,
	pointer = nil,
	hover = nil,
}

local function widgets()
	local data = settings.data
	local entries = type(data.widgets) == "table" and data.widgets or {}
	data.widgets = entries
	return entries
end

local function save()
	local ok, err = settings:write()
	if not ok then
		log(err)
	end
end

local function valid(widget)
	return type(widget) == "table"
		and (type(widget.id) == "string" or type(widget.color) == "string")
		and type(widget.x) == "number"
		and type(widget.y) == "number"
		and type(widget.width) == "number"
		and type(widget.height) == "number"
end

local function paint(widget)
	local preset = widget.id and presets[widget.id]
	local width = math.max(widget.width or (preset and preset.width) or 180, 1)
	local height = math.max(widget.height or (preset and preset.height) or 120, 1)
	if preset then
		return preset.view(preset, width, height)
	end
	-- Legacy entries store a palette color instead of a widget id.
	return iced.container(iced.space(), {
		width = width,
		height = height,
		style = {
			background = iced.opacity(theme[widget.color] or theme.primary, 85),
			border = { color = iced.opacity(theme.text, 30), width = 1, radius = 6 },
		},
	})
end

local function element(widget, index)
	return iced.pin(
		iced.mouse_area(paint(widget), {
			on_press = { event = "widgets:grab", args = { index = index } },
			on_right_press = { event = "widgets:remove", args = { index = index } },
			on_move = "widgets:hover:" .. index,
		}),
		{ x = widget.x or 0, y = widget.y or 0 }
	)
end

function desktop.list()
	return widgets()
end

function desktop.view()
	local elements = {}
	local drag = desktop.drag
	for index, widget in ipairs(widgets()) do
		if valid(widget) and not (drag and drag.index == index) then
			elements[#elements + 1] = element(widget, index)
		end
	end
	if drag then
		elements[#elements + 1] = iced.pin(paint(drag), { x = drag.x, y = drag.y })
	end
	return elements
end

function desktop.dragging()
	return desktop.drag ~= nil
end

local function place(drag)
	local list = widgets()
	local x, y = math.max(drag.x, 0), math.max(drag.y, 0)
	if drag.index then
		local widget = list[drag.index]
		if type(widget) == "table" then
			widget.x, widget.y = x, y
		end
	else
		list[#list + 1] = {
			id = drag.id,
			color = drag.color,
			x = x,
			y = y,
			width = drag.width,
			height = drag.height,
		}
	end
	save()
end

local function offset(widget, index, pointer)
	local width, height = widget.width or 180, widget.height or 120
	local hover = desktop.hover
	if hover and hover.index == index and hover.x >= 0 and hover.x <= width and hover.y >= 0 and hover.y <= height then
		return hover.x, hover.y
	end
	if pointer then
		local dx, dy = pointer.x - (widget.x or 0), pointer.y - (widget.y or 0)
		if dx >= 0 and dx <= width and dy >= 0 and dy <= height then
			return dx, dy
		end
	end
	return width / 2, height / 2
end

function desktop.update(event)
	if type(event) ~= "table" then
		return false
	end
	local hover_index = type(event.event) == "string" and event.event:match("^widgets:hover:(%d+)$")
	if hover_index and type(event.value) == "table" then
		desktop.hover = { index = tonumber(hover_index), x = event.value.x, y = event.value.y }
		return
	end
	if event.event == "widgets:add" then
		local entry = presets[event.args and event.args.id]
		if not entry then
			return
		end
		local pointer = desktop.pointer or { x = entry.width / 2, y = entry.height / 2 }
		desktop.drag = {
			id = entry.id,
			width = entry.width,
			height = entry.height,
			x = pointer.x - entry.width / 2,
			y = pointer.y - entry.height / 2,
			dx = entry.width / 2,
			dy = entry.height / 2,
		}
		return
	end
	if event.event == "widgets:grab" then
		local index = event.args and event.args.index
		local widget = index and widgets()[index]
		if not index or not valid(widget) then
			return
		end
		local dx, dy = offset(widget, index, desktop.pointer)
		desktop.drag = {
			index = index,
			id = widget.id,
			color = widget.color,
			width = widget.width,
			height = widget.height,
			x = widget.x,
			y = widget.y,
			dx = dx,
			dy = dy,
		}
		return
	end
	if event.event == "widgets:remove" then
		local index = event.args and event.args.index
		local list = widgets()
		if index and list[index] then
			table.remove(list, index)
			save()
		end
		return
	end
	if event.type ~= "mouse" then
		return false
	end
	if event.event == "move" then
		desktop.pointer = { x = event.x, y = event.y }
		if desktop.drag then
			desktop.drag.x = event.x - desktop.drag.dx
			desktop.drag.y = event.y - desktop.drag.dy
		end
		return
	end
	if event.event == "release" and event.button == "left" and desktop.drag then
		local drag = desktop.drag
		desktop.drag = nil
		place(drag)
		return
	end
	return false
end

return desktop
