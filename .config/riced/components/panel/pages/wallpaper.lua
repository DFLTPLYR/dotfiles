local box = require("components.box")

iced.define("wallpaper", function()
	local page = {}

	function page:view(props)
		local content = iced.column({
			iced.text("Wallpaper", {
				line_height = 4,
				shaping = "advanced",
				font = {
					weight = "bold",
				},
			}),
			iced.text("Wallpaper", {
				line_height = 2,
				font = {
					weight = "normal",
				},
			}),
			iced.button("file picker", {
				on_press = function()
					local dbus = riced.plugin("dbus")

					dbus.pick_file({
						title = "Choose a shader",
						path = "~/Pictures",
					}, function(paths, error)
						if error == "cancelled" then
							return
						end
						if error then
							log(error)
							return
						end
						local state = require("data.state")
						local file = require("data.settings").file
						local data = file.data
						data.background = paths[1]
						local ok, err = file:write(data)
						if not ok then
							log(err)
						end

						state.wallpaper_previous = state.wallpaper
						state.wallpaper = paths[1]
						state.wallpaper_progress = 0
						state.wallpaper_transitioning = true
					end)
				end,
			}),
		}, {
			width = iced.Length.fill,
			height = iced.Length.fill,
		})
		return iced.scrollable(content, {
			width = iced.Length.fill,
			height = iced.Length.fill,
		})
	end

	return page
end)
