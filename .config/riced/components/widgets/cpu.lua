-- CPU usage, clock speed and core count.

local card = require("components.widgets.card")

local function system()
	return riced.plugins("system")
end

local function cpu(entry, width, height)
	local store = system()
	local data = store and store.cpu
	if type(data) ~= "table" then
		return card.card(entry, width, height, card.placeholder("CPU unavailable"))
	end
	local usage = data.usage
	return card.card(entry, width, height, {
		card.big(usage and card.percent(usage) or "--"),
		card.note(string.format("%.2f GHz · %d cores", (data.frequency or 0) / 1000, data.cores or 0)),
		card.meter((usage or 0) / 100),
	})
end

return {
	id = "cpu",
	label = "CPU",
	icon = "cpu",
	width = 200,
	height = 150,
	view = cpu,
}
