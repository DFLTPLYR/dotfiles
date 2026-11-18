local state = require("data.state")
local shell = {}

local function online()
	local plugin = riced.plugins("applications")
	return plugin and plugin.alive or false
end

local function matches()
	if not online() then
		return {}
	end
	local entries = riced.plugins("applications").store.applications or {}
	local query = (state.app_menu_query or ""):lower()
	if query == "" then
		return entries
	end
	local found = {}
	for _, entry in ipairs(entries) do
		if (entry.name or ""):lower():find(query, 1, true) then
			found[#found + 1] = entry
		elseif (entry.id or ""):lower():find(query, 1, true) or (entry.comment or ""):lower():find(query, 1, true) then
			found[#found + 1] = entry
		end
	end
	return found
end

local function close()
	state.app_menu = false
	state.app_menu_query = ""
	state.app_menu_selected = 1
end

local function launch(id)
	local plugin = riced.plugins("applications")
	if not plugin or not plugin.alive then
		log("applications extension is offline")
		close()
		return
	end
	plugin.launch(id, function(_, error)
		if error then
			log(error)
		end
	end)
	close()
end

local ROW_HEIGHT = 56
local ROW_SPACING = 2
local VISIBLE_ROWS = 5

local function scroll()
	local selected = state.app_menu_selected or 1
	local first = math.floor((selected - 1) / VISIBLE_ROWS) * VISIBLE_ROWS
	local y = first * (ROW_HEIGHT + ROW_SPACING)
	return {
		type = "scroll_to",
		id = "app_menu_results",
		y = y,
	}
end

-- Called from data/events.lua while the app menu is open. Returns false when
-- the event is not ours, otherwise nil or a task.
function shell.update(event)
	if type(event) ~= "table" then
		return false
	end
	if event.event == "app_menu_launch" then
		launch(event.args)
		return nil
	end
	if event.type ~= "key" or event.event ~= "press" then
		return false
	end
	if event.key == "Escape" then
		close()
		return nil
	end
	if event.key == "Backspace" then
		state.app_menu_query = (state.app_menu_query or ""):sub(1, -2)
		state.app_menu_selected = 1
		return scroll()
	end
	local entries = matches()
	local count = #entries
	local selected = math.min(math.max(state.app_menu_selected or 1, 1), math.max(count, 1))
	if event.key == "ArrowDown" and count > 0 then
		state.app_menu_selected = selected % count + 1
		return scroll()
	elseif event.key == "ArrowUp" and count > 0 then
		state.app_menu_selected = (selected - 2) % count + 1
		return scroll()
	elseif event.key == "Enter" and count > 0 then
		launch(entries[selected].id)
		return nil
	end
	local modifiers = event.modifiers or {}
	if event.text and event.text ~= "" and not (modifiers.control or modifiers.alt or modifiers.logo) then
		state.app_menu_query = (state.app_menu_query or "") .. event.text
		state.app_menu_selected = 1
		return scroll()
	end
	return false
end

local PATHS = {}

local function icon(entry)
	local name = entry.icon
	local key = name and (name .. "\0" .. iced.icon_theme)
	local path = key and PATHS[key]
	if path == nil then
		path = key and iced.icon_path(name, { size = 24, thumbnail = true }) or false
		if key then
			PATHS[key] = path
		end
	end
	if not path then
		return iced.space(nil, { width = 24, height = 24 })
	end
	local props = { width = 24, height = 24, content_fit = "contain" }
	if path:sub(-4):lower() == ".svg" then
		return iced.svg(path, props)
	end
	return iced.image(path, props)
end

local function row(entry, active)
	local title = active and theme.primary or theme.text
	local detail = active and theme.background or theme.secondary
	return iced.button(
		iced.row({
			icon(entry),
			iced.column({
				iced.text(entry.name or entry.id or "?", { color = title }),
				iced.text(entry.comment or entry.id or "", {
					size = 12,
					color = detail,
					wrap = "none",
				}),
			}, { spacing = 2, width = iced.Length.fill }),
		}, { spacing = 12, align_y = "center", width = iced.Length.fill }),
		{
			width = iced.Length.fill,
			height = ROW_HEIGHT,
			on_press = { event = "app_menu_launch", args = entry.id },
			style = {
				background = active and iced.opacity(theme.primary, 20) or iced.opacity(theme.background, 20),
				hovered = {
					background = iced.opacity(theme.background, 20),
				},
			},
		}
	)
end

local function picker()
	local entries = matches()
	local selected = math.min(math.max(state.app_menu_selected or 1, 1), math.max(#entries, 1))
	local results
	if #entries == 0 then
		results = iced.container(
			iced.text(
				online() and "no matches" or "applications extension is offline",
				{ color = iced.opacity(theme.secondary, 70) }
			),
			{ width = iced.Length.fill, height = iced.Length.fill, align_x = "center", align_y = "center" }
		)
	else
		results = iced.scrollable(
			iced.list_view(entries, {
				id = "app_menu_list",
				key = "id",
				spacing = ROW_SPACING,
				render = function(entry, index)
					return row(entry, index + 1 == selected)
				end,
			}),
			{
				id = "app_menu_results",
				height = iced.Length.fill,
				scrollbar_hidden = true,
			}
		)
	end

	local query = state.app_menu_query or ""
	local search = iced.container(
		iced.text(
			query ~= "" and query or "Search applications",
			{ color = query ~= "" and theme.text or theme.secondary }
		),
		{
			width = iced.Length.fill,
			padding = { top = 8, right = 10, bottom = 8, left = 10 },
			style = {
				background = iced.opacity(theme.secondary, 10),
				border = { color = theme.secondary, width = 1, radius = 2 },
			},
		}
	)

	return iced.container(
		iced.column({
			iced.text("Applications", { size = 20, color = theme.primary }),
			search,
			results,
			iced.text("Type to search · Enter launch · Esc close · ↑↓ select", {
				size = 12,
				color = theme.secondary,
			}),
		}, { spacing = 12, width = iced.Length.fill, height = iced.Length.fill }),
		{
			width = 560,
			height = 420,
			padding = 16,
			style = {
				background = iced.opacity(theme.background, 70),
				border = { color = theme.primary, width = 1, radius = 2 },
			},
		}
	)
end

-- Only the picker takes clicks; the rest of the overlay stays transparent.
local function content()
	local menu = iced.measure(picker(), { id = "menu" })
	return iced.container(iced.region(menu), {
		width = iced.Length.fill,
		height = iced.Length.fill,
		align_x = "center",
		align_y = "center",
	})
end

function shell.view()
	local bounds = iced.bounds("menu")
	local blur = "none"
	if bounds and bounds.width > 0 and bounds.height > 0 then
		blur = {
			{ x = bounds.x, y = bounds.y, width = bounds.width, height = bounds.height },
		}
	end
	return iced.layer(content(), {
		id = "app_menu",
		size = iced.Size(iced.Extent.fill, iced.Extent.fill),
		layer = iced.Layer.overlay,
		anchor = { "top", "bottom", "left", "right" },
		exclusive_zone = -1,
		keyboard_interactivity = iced.KeyboardInteractivity.exclusive,
		output_option = iced.Output.last_output,
		events_transparent = true,
		namespace = "riced-appmenu",
		blur_option = blur,
	})
end

return shell
