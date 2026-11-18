local box = require("components.box")
local weather = require("extensions.openmeteo.openmeteo")
weather.configure(14.082809573743582, 120.83566060057112)

local shell = {
	side = "top",
	height = 40,
	menu = false,
}
local function slots(content, props, gap)
	return iced.container(iced.row(content, { spacing = gap }), props)
end
function shell.view(props)
	local anchor_pos = {
		top = { "left", "right", "top" },
		bottom = { "left", "right", "bottom" },
		left = { "left", "top", "bottom" },
		right = { "right", "top", "bottom" },
	}
	local vertical = shell.side == "top" or shell.side == "bottom"
	local anchor_size = vertical and { width = iced.Length.fill, height = shell.height }
		or { width = shell.height, height = iced.Length.fill }

	local left = {
		iced.workspaces({ id = "navbar workspaces" }),
	}

	-- %a	abbreviated weekday name (e.g., Wed)
	-- %A	full weekday name (e.g., Wednesday)
	-- %b	abbreviated month name (e.g., Sep)
	-- %B	full month name (e.g., September)
	-- %c	date and time (e.g., 09/16/98 23:48:10)
	-- %d	day of the month (16) [01-31]
	-- %H	hour, using a 24-hour clock (23) [00-23]
	-- %I	hour, using a 12-hour clock (11) [01-12]
	-- %M	minute (48) [00-59]
	-- %m	month (09) [01-12]
	-- %p	either "am" or "pm" (pm)
	-- %S	second (10) [00-61]
	-- %w	weekday (3) [0-6 = Sunday-Saturday]
	-- %x	date (e.g., 09/16/98)
	-- %X	time (e.g., 23:48:10)
	-- %Y	full year (1998)
	-- %y	two-digit year (98) [00-99]
	-- %%	the character `%´

	local center = {
		box(iced.clock({ id = "clock-date", format = "%a %b %d" }, iced.variant("navbar_middle"))),
		box(iced.clock({ id = "clock-time", format = "%I:%M:%S %p " }, iced.variant("navbar_middle"))),
		box(iced.openmeteo(iced.variant("navbar_middle"))),
	}

	local right = {
		iced.systemtray(shell),
		iced.systembtn(),
	}
	local content = iced.container(iced.row({
		slots(left, {
			height = iced.Length.fill,
			width = iced.Length.fill,
			padding = 4,
			align_y = "center",
		}, 0),
		slots(center, {
			width = iced.Length.fill,
			height = iced.Length.fill,
			align_x = "center",
			align_y = "center",
		}, 4),
		slots(right, {
			height = iced.Length.fill,
			width = iced.Length.fill,
			align_y = "center",
			align_x = "right",
		}, 4),
	}))

	return iced.layer(content, {
		id = "top",
		size = anchor_size,
		anchor = anchor_pos[shell.side],
		exclusive_zone = shell.height,
		blur_option = "none",
	})
end

return shell
