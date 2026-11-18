iced.define("notification_list", function()
	local notification = {}

	function notification:view(notifications)
		return iced.list_view(notifications, {
			id = "notification_list",
			key = "id",
			width = 320,
			spacing = 8,
			transition = iced.transition("list_motion"),
			render = function(item)
				return iced.notification_container(item)
			end,
		})
	end

	return notification
end)
