local state = require("data.state")
local events = {}

-- on_press can be a plain string, or events.send(name, args) when a handler needs arguments.
function events.send(event, args)
	return { event = event, args = args }
end

function events.dismiss(id, restore)
	state.dismissed = state.dismissed or {}
	state.dismissed[id] = true
	riced.plugin("dbus").close_notification(id, function(result, err)
		if err then
			state.dismissed[id] = nil
			if restore then
				restore()
			end
			log("notification dismiss failed", err)
		end
	end)
end

local handlers = {
	top = {
		workspace = function(self, args)
			if args and args.id then
				os.execute("hyprctl dispatch 'hl.dsp.focus({workspace = " .. args.id .. "})' >/dev/null 2>&1")
			end
		end,
	},
}
function events.update(self, event, component)
	if type(event) == "table" and event.type == "window_closed" and event.id == "settings" then
		state.close_settings()
		return
	end
	if state.app_menu then
		local appmenu = require("components.layers.appmenu.appmenu")
		local result = appmenu.update(event)
		if result ~= false then
			return result
		end
	end
	if state.settings then
		if type(event) == "table" and event.type == "key" and event.event == "press" and event.key == "Escape" then
			state.close_settings()
			return
		end
		local result = require("components.layers.settings.pages.outputs").update(event)
		if result ~= false then
			return result
		end
	end
	local name = type(event) == "table" and event.event or event
	local args = type(event) == "table" and event.args or nil
	if type(name) ~= "string" then
		return
	end

	local group, action = name:match("^([^:]+):(.*)$")
	if group then
		local bucket = handlers[group]
		if type(bucket) == "table" then
			local handler = bucket[action] or bucket._
			if handler then
				return handler(self, args)
			end
		elseif bucket then
			return bucket(self, args)
		end
	else
		local handler = handlers[name]
		if handler then
			return handler(self, args)
		end
	end
end

return events
