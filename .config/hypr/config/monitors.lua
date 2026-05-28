hl.monitor({
	output = "DP-1",
	mode = "1920x1080@164.96",
	position = "0x840",
	scale = 1.0,
})

hl.monitor({
	output = "DP-2",
	mode = "1920x1080@165.0",
	position = "1920x0",
	scale = 1.0,
	transform = 3,
})

local wr = hl.workspace_rule
local winr = hl.window_rule

for i = 1, 9 do
	local wsh = tostring(i)
	local wsv = tostring(i + 100)

	wr({ workspace = wsh, default_name = "H" .. tostring(i), monitor = "DP-1", default = (i == 1) })
	wr({ workspace = wsv, default_name = "V" .. tostring(i), monitor = "DP-2", default = (i == 1) })
end

wr({ workspace = "m[DP-1]", layout_opts = { direction = "right" } })
winr({ match = { workspace = "m[DP-1]" }, scrolling_width = 0.8 })

wr({ workspace = "m[DP-2]", layout_opts = { direction = "down" } })
winr({ match = { workspace = "m[DP-2]" }, scrolling_width = 0.33333 })
