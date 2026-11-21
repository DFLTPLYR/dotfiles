local desktop = require("components.desktop_widgets")

local shell = {
	drag = false,
}

local FALLBACK_SIZE = 1920

-- Use the output size instead of the layer props: every surface's view receives
-- its own props, which would generate several wallpaper sizes.
local function wallpaper_size()
	local wayland = riced.plugins("wayland")
	if wayland and wayland.alive then
		local size = 0
		for _, output in ipairs(wayland.store.outputs or {}) do
			size = math.max(size, output.width or 0, output.height or 0)
		end
		if size > 0 then
			return size
		end
	end
	return FALLBACK_SIZE
end

local function resolve(path)
	return path and iced.icon_path(path, { size = wallpaper_size(), thumbnail = true })
end

local function content(current, previous, progress)
	local new = resolve(current)
	if not new then
		return iced.container(iced.space(), {
			width = iced.Length.fill,
			height = iced.Length.fill,
			style = { background = theme.background },
		})
	end
	local old = previous and previous ~= current and resolve(previous) or nil
	local textures = old and { old, new } or { new }
	local background = iced.shader({
		path = "components/shaders/wallpaper.wgsl",
		width = iced.Length.fill,
		height = iced.Length.fill,
		textures = textures,
		transition = {
			change = {
				props = { "extraArgs.progress" },
				duration = 1,
				callback = function(self)
					local themeagen = riced.plugins("themeagen")
					themeagen.generate({ image = require("data.state").wallpaper, mode = themeagen.mode or "dark" }, function(_, error)
						if error then
							log(error)
						end
					end)
				end,
			},
		},
		-- progress 0 shows texture0; during a change texture0 is the old wallpaper.
		extraArgs = { progress = old and progress or 0 },
	})

	return iced.stack({ background }, {})
end

function shell.view(current, previous, progress)
	local layers = {
		content(current, previous, progress),
		iced.mouse_area(
			iced.container(iced.space(), {
				width = iced.Length.fill,
				height = iced.Length.fill,
			}),
			{}
		),
	}
	for _, widget in ipairs(desktop.view()) do
		layers[#layers + 1] = widget
	end

	return iced.layer(
		iced.stack(layers),
		{
			id = "background",
			size = iced.Size(iced.Extent.fill, iced.Extent.fill),
			-- Promote above windows while a widget is dragged so the preview is visible.
			layer = desktop.dragging() and iced.Layer.overlay or iced.Layer.background,
			anchor = { "top", "bottom", "left", "right" },
			exclusive_zone = -1,
			keyboard_interactivity = iced.KeyboardInteractivity.none,
			output_option = iced.Output.active,
			events_transparent = false,
			namespace = "riced-background",
		}
	)
end

return shell
