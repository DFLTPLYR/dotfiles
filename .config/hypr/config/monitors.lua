local monitors = {
	{ output = "DP-1", mode = "1920x1080@164.96", position = "0x840", scale = 1.0 },
	{ output = "DP-2", mode = "1920x1080@165.0", position = "1920x0", scale = 1.0, transform = 3 },
}

for _, cfg in ipairs(monitors) do
	hl.monitor(cfg)
end

local wr = hl.workspace_rule
local winr = hl.window_rule

for i, mon in ipairs(monitors) do
	local offset = (i - 1) * 1000
	for j = 1, 9 do
		wr({ workspace = tostring(j + offset), monitor = mon.output, default = (j == 1) })
	end

	local dir = i == 1 and "right" or "down"
	wr({ workspace = "m[" .. mon.output .. "]", layout_opts = { direction = dir } })
	winr({ match = { workspace = "m[" .. mon.output .. "]" }, scrolling_width = i == 1 and 0.8 or 0.33333 })
end
