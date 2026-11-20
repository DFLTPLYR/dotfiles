-- Display arrangement preview: drag output rectangles on a grid.
-- Positions are preview-only and persist in data/settings.json.

local state = require("data.state")
local settings = require("data.settings").file

local page = {
	positions = nil,
	press = nil,
	pointer = nil,
}

local MAP_WIDTH = 520
local MAP_HEIGHT = 340
local PADDING = 20
local GRID = 16
local GRID_STEP = 32

local function live()
	local plugin = riced.plugins("wayland")
	if not plugin or not plugin.alive then
		return {}
	end
	return plugin.store.outputs or {}
end

local function outputs()
	local known = page.positions
	if not known then
		known = {}
		local saved = settings.data.outputs
		if type(saved) == "table" then
			for _, entry in ipairs(saved) do
				if
					type(entry) == "table"
					and type(entry.name) == "string"
					and type(entry.x) == "number"
					and type(entry.y) == "number"
				then
					known[entry.name] = { x = entry.x, y = entry.y }
				end
			end
		end
		page.positions = known
	end

	local list = {}
	for _, output in ipairs(live()) do
		local position = known[output.name]
		if not position then
			position = { x = output.x or 0, y = output.y or 0 }
			known[output.name] = position
		end
		list[#list + 1] = {
			name = output.name,
			x = position.x,
			y = position.y,
			-- wl_output reports the mode in physical pixels but x/y in logical coords.
			width = math.max((output.width or 1) / math.max(output.scale or 1, 1), 1),
			height = math.max((output.height or 1) / math.max(output.scale or 1, 1), 1),
		}
	end
	return list
end

local function fit(list)
	if #list == 0 then
		return nil
	end

	local minx, miny, maxx, maxy = math.huge, math.huge, -math.huge, -math.huge
	for _, output in ipairs(list) do
		minx = math.min(minx, output.x)
		miny = math.min(miny, output.y)
		maxx = math.max(maxx, output.x + output.width)
		maxy = math.max(maxy, output.y + output.height)
	end

	local width = math.max(maxx - minx, 1)
	local height = math.max(maxy - miny, 1)
	local scale = math.min((MAP_WIDTH - 2 * PADDING) / width, (MAP_HEIGHT - 2 * PADDING) / height)
	return {
		scale = scale,
		x = (MAP_WIDTH - width * scale) / 2,
		y = (MAP_HEIGHT - height * scale) / 2,
		minx = minx,
		miny = miny,
		width = width,
		height = height,
	}
end

local function snap(value)
	return math.floor(value / GRID + 0.5) * GRID
end

local function save()
	local saved = {}
	local seen = {}
	for _, output in ipairs(live()) do
		local position = page.positions[output.name]
		if position then
			saved[#saved + 1] = { name = output.name, x = position.x, y = position.y }
			seen[output.name] = true
		end
	end
	-- Keep positions of outputs that are currently disconnected.
	for name, position in pairs(page.positions) do
		if not seen[name] then
			saved[#saved + 1] = { name = name, x = position.x, y = position.y }
		end
	end

	local data = settings.data
	data.outputs = saved
	settings.data = data
	local ok, err = settings:write()
	if not ok then
		log(err)
	end
end

function page.update(event)
	if type(event) ~= "table" then
		return false
	end

	if event.event == "outputs:press" then
		local name = event.args and event.args.name
		local position = name and page.positions and page.positions[name]
		if not position then
			return
		end
		page.press = {
			name = name,
			x = position.x,
			y = position.y,
			px = page.pointer and page.pointer.x,
			py = page.pointer and page.pointer.y,
			pending = page.pointer == nil,
			scale = page.layout and page.layout.scale or 1,
		}
		return
	end

	if event.event == "outputs:move" then
		local point = event.value
		if type(point) ~= "table" then
			return false
		end
		page.pointer = point

		local press = page.press
		if not press then
			return
		end
		if press.pending then
			press.px, press.py = point.x, point.y
			press.pending = false
			return
		end

		local position = page.positions[press.name]
		if not position then
			return
		end
		position.x = snap(press.x + (point.x - press.px) / press.scale)
		position.y = snap(press.y + (point.y - press.py) / press.scale)
		return
	end

	-- The app-wide mouse subscription ends drags released outside the map.
	if event.type == "mouse" and event.event == "release" and event.button == "left" then
		local press = page.press
		page.press = nil
		if press then
			save()
		end
		return
	end

	return false
end

local function grid()
	local shapes = {}
	local color = iced.opacity(theme.text, 12)
	for x = 0, MAP_WIDTH, GRID_STEP do
		shapes[#shapes + 1] = {
			type = "line",
			from = { x = x, y = 0 },
			to = { x = x, y = MAP_HEIGHT },
			color = color,
			width = 1,
		}
	end
	for y = 0, MAP_HEIGHT, GRID_STEP do
		shapes[#shapes + 1] = {
			type = "line",
			from = { x = 0, y = y },
			to = { x = MAP_WIDTH, y = y },
			color = color,
			width = 1,
		}
	end
	return shapes
end

local function frame(output, layout, pressed)
	local width = output.width * layout.scale
	local height = output.height * layout.scale
	return iced.pin(
		iced.mouse_area(
			iced.container(iced.text(output.name, { size = 11, color = theme.text }), {
				width = width,
				height = height,
				align_x = "center",
				align_y = "center",
				style = {
					background = pressed and iced.opacity(theme.primary, 30)
						or iced.opacity(theme.primary, 12),
					border = {
						color = pressed and theme.success or theme.primary,
						width = pressed and 2 or 1,
						radius = 2,
					},
				},
			}),
			{
				on_press = { event = "outputs:press", args = { name = output.name } },
			}
		),
		{
			x = layout.x + (output.x - layout.minx) * layout.scale,
			y = layout.y + (output.y - layout.miny) * layout.scale,
		}
	)
end

local function map()
	local list = outputs()
	local layout = fit(list)
	page.layout = layout
	local layers = {}

	if layout and type(state.wallpaper) == "string" and state.wallpaper ~= "" then
		layers[#layers + 1] = iced.pin(
			iced.image(iced.icon_path(state.wallpaper, { size = 1024, thumbnail = true }) or state.wallpaper, {
				width = layout.width * layout.scale,
				height = layout.height * layout.scale,
				content_fit = "cover",
			}),
			{ x = layout.x, y = layout.y }
		)
	end

	layers[#layers + 1] = iced.canvas(grid(), {
		width = MAP_WIDTH,
		height = MAP_HEIGHT,
	})

	if layout then
		for _, output in ipairs(list) do
			layers[#layers + 1] =
				frame(output, layout, page.press and page.press.name == output.name)
		end
	else
		layers[#layers + 1] = iced.container(
			iced.text("no wayland outputs", { size = 12, color = theme.text }),
			{
				width = MAP_WIDTH,
				height = MAP_HEIGHT,
				align_x = "center",
				align_y = "center",
			}
		)
	end

	return iced.container(
		iced.mouse_area(iced.stack(layers, { width = MAP_WIDTH, height = MAP_HEIGHT }), {
			on_move = "outputs:move",
		}),
		{
			width = MAP_WIDTH,
			height = MAP_HEIGHT,
			clip = true,
			style = { background = iced.opacity(theme.background, 90) },
		}
	)
end

iced.define("outputs", function()
	local widget = {}

	function widget:view(props)
		return map()
	end

	return widget
end)

return page
