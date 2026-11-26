-- Memory usage in GiB with a usage bar.

local card = require("components.widgets.card")

local function system()
	return riced.plugins("system")
end

local function ram(entry, width, height)
	local store = system()
	local data = store and store.memory
	if type(data) ~= "table" or not data.total or data.total <= 0 then
		return card.card(entry, width, height, card.placeholder("Memory unavailable"))
	end
	local ratio = (data.used or 0) / data.total
	return card.card(entry, width, height, {
		card.big(string.format("%.1f / %.1f GiB", card.gib(data.used), card.gib(data.total)), 20),
		card.note(string.format("%.0f%% used", ratio * 100)),
		card.meter(ratio),
	})
end

return {
	id = "ram",
	label = "RAM",
	icon = "memory-stick",
	width = 160,
	height = 180,
	view = ram,
}
