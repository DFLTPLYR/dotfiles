iced.define("workspaces", function()
	local widget = {}

	function widget:view(props)
		local wayland = riced.plugins("wayland")
		return iced.list_view(wayland.store.workspaces or {}, {
			id = props.id,
			key = "id",
			spacing = 2,
			transition = iced.transition("list_motion", {
				enter = { from = { y = -180, scale = 0 }, duration = 200 },
				exit = { to = { y = -180, scale = 0 }, duration = 100 },
			}),
			direction = "horizontal",
			render = function(item, index)
				return iced.button(
					iced.text(index + 1, { center = true }),
					iced.variant("workspaces", {
						width = item.active and 40 or 20,
						style = {
							background = item.urgent and theme.danger
								or item.active and theme.primary
								or iced.opacity(theme.secondary, 50),
							border = {
								color = item.urgent and theme.danger or theme.background,
								radius = item.active and 2 or 4,
							},
						},
						on_press = item.active and nil or { event = "top:workspace", args = { id = item.name } },
						transition = iced.transition("basic"),
					})
				)
			end,
		})
	end

	return widget
end)
