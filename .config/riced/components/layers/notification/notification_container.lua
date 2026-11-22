iced.define("notification_container", function()
	local notification = {}

	function notification:view(item)
		return iced.container(
			iced.region(iced.column({
				iced.row({
					iced.text(item.app_name, { size = 12, width = iced.Length.fill, wrap = "word_or_glyph" }),
					iced.button("Dismiss", {
						on_press = function()
							require("data.events").dismiss(item.id)
						end,
					}),
				}, { spacing = 8 }),
				iced.text(item.summary, { size = 16, width = iced.Length.fill, wrap = "word_or_glyph" }),
				iced.text(item.body, { size = 14, width = iced.Length.fill, wrap = "word_or_glyph" }),
			}, { spacing = 4, padding = 12, width = iced.Length.fill })),
			{
				width = iced.Length.fill,
				transition = iced.transition("notification_motion", {
					press = {
						callback = function()
							require("data.events").dismiss(item.id)
						end,
					},
				}),
				style = {
					background = theme.background,
					text_color = theme.text,
					border = { color = theme.danger, width = 2 },
				},
			}
		)
	end

	return notification
end)
