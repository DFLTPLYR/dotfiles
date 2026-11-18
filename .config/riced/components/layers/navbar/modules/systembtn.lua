iced.define("systembtn", function()
	local widget = { open = false }

	local sys = {
		{ label = "Suspend", action = "suspend" },
		{ label = "Hibernate", action = "hibernate" },
		{ label = "Reboot", action = "reboot" },
		{ label = "Power off", action = "poweroff" },
	}
	function widget:view()
		local button = iced.button(iced.lucide({ name = "power", size = 16, center = true }), {
			id = "powerbtn",
			on_press = function()
				widget.open = not widget.open
			end,
			width = 20,
			height = iced.Length.fill,
			style = {
				background = "#00000000",
				text_color = iced.opacity(theme.text, 100),
				hovered = {
					background = iced.opacity(theme.text, 12),
				},
			},
		})

		local popup = iced.popup(
			iced.container(
				iced.list_view(sys, {
					id = "power_actions",
					key = "action",
					direction = "vertical",
					spacing = 2,
					width = iced.Length.fill,
					height = iced.Length.fill,
					render = function(item)
						return iced.button(item.label, {
							width = iced.Length.fill,
							height = 28,
							padding = 4,
							on_press = function()
								widget.open = false
								os.execute("systemctl " .. item.action)
							end,
							style = {
								background = "#00000000",
								text_color = theme.text,
								hovered = { background = iced.opacity(theme.text, 12) },
							},
						})
					end,
				}),
				{
					width = iced.Length.fill,
					height = iced.Length.fill,
					style = {
						background = iced.opacity(theme.background, 40),
						border = { color = iced.opacity(theme.text, 20), width = 1 },
					},
				}
			),
			{
				id = "power_menu",
				visible = widget.open,
				width = 180,
				height = 120,
				anchor = "powerbtn",
				on_closed = function()
					widget.open = false
				end,
			}
		)

		return iced.stack({
			button,
			popup,
		})
	end

	return widget
end)
