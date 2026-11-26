-- Desktop widgets: example cards placed on the wallpaper layer.
-- Left-press to drag (the background layer promotes to overlay), right-press to
-- remove. The settings Widgets page adds new ones with "widgets:add".
-- Each widget lives in components/widgets/<id>.lua; this module only places them.

local settings = require("data.settings").file
local catalog = require("components.widgets.catalog")

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
			id = index,
			on_press_delay = 300,
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

local function active_size()
	local wayland = riced.plugins("wayland")
	local store = wayland and wayland.alive and wayland.store
	local focused = store and store.focused and store.focused.output
	for _, output in ipairs(store and store.outputs or {}) do
		if output.name == focused then
			-- Positions are logical; wl_output reports the mode in physical pixels.
			local scale = math.max(output.scale or 1, 1)
			return (output.width or 0) / scale, (output.height or 0) / scale
		end
	end
end

local function clamp_position(value, extent, size)
	local position = math.max(math.floor(value), 0)
	if extent and extent > 0 then
		position = math.min(position, math.max(extent - size, 0))
	end
	return math.floor(position)
end

local function place(drag)
	local list = widgets()
	local max_x, max_y = active_size()
	local x = clamp_position(drag.x, max_x, drag.width or 0)
	local y = clamp_position(drag.y, max_y, drag.height or 0)
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
