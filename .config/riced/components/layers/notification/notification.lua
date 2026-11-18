local dbus = riced.plugin("dbus")
local state = require("data.state")
local shell = {}
local function content(props)
	state.dismissed = state.dismissed or {}
	local live = {}
	local notifications = {}
	for _, notification in ipairs(dbus.notifications or {}) do
		live[notification.id] = true
		if not state.dismissed[notification.id] then
			notifications[#notifications + 1] = notification
		end
	end
	for id in pairs(state.dismissed) do
		if not live[id] then
			state.dismissed[id] = nil
		end
	end

	-- Keep the list mounted while empty so the last card can animate out.
	local body = iced.scrollable(iced.notification_list(notifications), {
		id = "notification_scroll",
		width = 320,
		height = props.height,
		direction = "vertical",
		scrollbar_hidden = true,
	})

	return iced.container(body, {
		width = iced.Extent.fill,
		height = iced.Extent.fill,
		padding = 16,
		align_x = "right",
		align_y = "top",
	})
end
function shell.view(props)
	return iced.layer(content(props), {
		id = "notification",
		layer = iced.Layer.overlay,
		size = iced.Size(352, iced.Extent.fill),
		anchor = { "top", "bottom", "right" },
		exclusive_zone = -1,
		keyboard_interactivity = iced.KeyboardInteractivity.none,
		output_option = iced.Output.active,
		events_transparent = true,
		namespace = "riced-notifications",
		blur_option = "none",
	})
end

return shell
