require("components.motion")
riced.stylesheet = require("components.style.stylesheet")
local dbus = riced.plugin("dbus")
local raw_log = log -- original callable table
local last, last_at = nil, 0

log = setmetatable({ table = raw_log.table }, {
	__call = function(_, ...)
		local values = table.pack(...)
		for i = 1, values.n do
			values[i] = tostring(values[i])
		end
		local message = table.concat(values, "\t", 1, values.n)
		raw_log(...) -- keep writing to stderr/logs

		if not dbus.alive or message == "" then
			return
		end
		local now = os.time()
		if message == last and now - last_at < 30 then
			return
		end -- debounce repeats
		last, last_at = message, now
		dbus.notify({
			summary = "riced",
			body = message:match("^[^\n]*") or message, -- first line; tracebacks stay in the log
			icon = "dialog-error",
		}, function(_, err)
			if err then
				raw_log(err)
			end -- raw_log, not log: avoids a notify loop
		end)
	end,
})

local app = {}
-- Late-bind through the module table so editing data/events.lua takes effect
-- without restarting riced. `app.update = events.update` would cache the old
-- function object across module reloads.

local themeagen = riced.plugins("themeagen")
local generating = false
local function generated_theme()
	local colors = themeagen.colors
	local active = colors and colors[themeagen.mode]
	if not active then
		if themeagen.alive and not generating then
			generating = true
			themeagen.generate({ seed = "#b8bb26", mode = "dark" }, function(_, error)
				generating = false
				if error then
					log(error)
				end
			end)
		end
		return nil
	end
	local theme = {
		background = active.background or active.surface,
		text = active.onsurface,
		primary = active.primary,
		secondary = active.secondary,
		success = active.terminal.normal.green,
		warning = active.terminal.normal.yellow,
		danger = active.error,
	}
	return theme
end
local function active_theme()
	local value = generated_theme() or config.theme
	theme = value
	return value
end

function app:update(event, component)
	local state = require("data.state")
	local screenshot = require("components.screenshot")

	if type(event) == "table" and event.type == "log" then
		dbus.notify({
			summary = "riced " .. event.level,
			body = event.target .. ": " .. (event.message:match("^[^\n]*") or event.message),
			icon = "dialog-error",
			urgency = event.level == "error" and "critical" or "normal",
		}, function(_, err)
			if err then
				log(err)
			end
		end)
		return
	end
	if type(event) == "table" and event.type == "tick" and state.wallpaper_transitioning then
		state.wallpaper_progress = math.min(state.wallpaper_progress + 1 / 45, 1)
		if state.wallpaper_progress >= 1 then
			state.wallpaper_previous = state.wallpaper
			state.wallpaper_transitioning = false
		end
		return
	elseif event == "screenshot" then
		screenshot.capture(self)
	end
	return require("data.events").update(self, event, component)
end

function app:view(props)
	active_theme()
	local state = require("data.state")
	local background = require("components.layers.background.background")
	local bar = require("components.layers.navbar.bar")
	local dock = require("components.layers.dock.dock")
	local notification = require("components.layers.notification.notification")

	local layers = {
		background.view(state.wallpaper, state.wallpaper_previous, state.wallpaper_progress),
		bar.view(props),
		notification.view(props),
		-- dock.view(props),
	}

	if state.settings then
		table.insert(layers, require("components.panel.settings").view(props))
	end

	if state.app_menu then
		table.insert(layers, require("components.layers.appmenu.appmenu").view(props))
	end

	-- returns a iced.layer
	return layers
end

function app:title(window)
	return "riced"
end
function app:subscription(active)
	local subscriptions = {}
	local state = require("data.state")
	if state.app_menu then
		subscriptions[#subscriptions + 1] = iced.on_key(true)
	end
	if state.wallpaper_transitioning then
		subscriptions[#subscriptions + 1] = iced.every(16)
	end
	-- subscriptions[#subscriptions + 1] = iced.on_mouse()
	if #subscriptions == 0 then
		return nil
	end
	return subscriptions
end -- or iced.every(1000), sends { type = "tick" }
function app:style()
	-- Palette argument is config.theme; the global tracks the generated theme.
	return { background_color = "#00000000", text_color = theme.text }
end
function app:redraw_scope(event)
	return "all"
end

function app:theme(window)
	return active_theme()
end

return riced
	.daemon(app, "riced", app.update, app.view)
	:title(app.title)
	:subscription(app.subscription)
	:theme(app.theme)
	:style(app.style)
	:redraw_scope(app.redraw_scope)
	:settings({
		id = "riced",
		-- Use "active" to display a surface; "background" starts without one.
		layer_settings = {
			start_mode = "background",
			keyboard_interactivity = iced.KeyboardInteractivity.none,
		},
	})
	:run()
