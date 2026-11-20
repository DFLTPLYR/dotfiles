---@class TopLayer
---@field test boolean

---@class State
---@field settings boolean

---@class State
---@field app_menu boolean
---@field app_menu_query string
---@field app_menu_selected integer

---@class State
---@field wallpaper string
---@field wallpaper_previous string|nil
---@field wallpaper_progress number
---@field wallpaper_transitioning boolean

---@type State
local state = {
	settings = false,
	app_menu = false,
	app_menu_query = "",
	app_menu_selected = 1,
	dismissed = {},
	wallpaper = require("data.settings").file.data.background,
	wallpaper_previous = nil,
	wallpaper_progress = 0,
	wallpaper_transitioning = false,
}

local screenshot = require("components.screenshot")

function state.close_settings()
	state.settings = false
end

riced.ipc({
	settings = function(self, args)
		if #args ~= 0 then
			error("usage: riced ipc settings")
		end
		if state.settings then
			state.close_settings()
		else
			state.settings = true
		end
	end,
	app_menu = function(self, args)
		if #args ~= 0 then
			error("usage: riced ipc app_menu")
		end
		state.app_menu = not state.app_menu
		state.app_menu_query = ""
		state.app_menu_selected = 1
	end,
	add = function(self, args)
		return self:add_bar(args)
	end,
	screenshot = function(self, args)
		if #args > 1 then
			error("usage: riced ipc screenshot [output]")
		end
		local dbus = riced.plugin("dbus")
		local path = "~/Pictures/Screenshots/" .. os.date("%Y%m%d-%H%M%S") .. ".png"
		riced.plugin("screenshot").capture(args[1], path, function(last, err)
			if err then
				log(err)
				return
			end
			dbus.notify({
				summary = "Screenshot saved",
				body = last.path, -- absolute path the extension wrote
				icon = "accessories-screenshot",
				timeout = 4000,
			}, function(_, notify_err)
				if notify_err then
					log(notify_err)
				end
			end)
		end)
		log("test")
	end,
})

return state
