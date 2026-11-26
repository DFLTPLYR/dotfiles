-- GPU load, temperature and VRAM usage.

local card = require("components.widgets.card")

local function system()
	return riced.plugins("system")
end

local function gpu(entry, width, height)
	local store = system()
	local data = store and store.gpus and store.gpus[1]
	if type(data) ~= "table" then
		return card.card(entry, width, height, card.placeholder("GPU unavailable"))
	end
	local detail = {}
	if data.temp then
		detail[#detail + 1] = string.format("%.0f°C", data.temp)
	end
	if data.vram_used and data.vram_total then
		detail[#detail + 1] = string.format("%.1f / %.1f GiB", card.gib(data.vram_used), card.gib(data.vram_total))
	end
	return card.card(entry, width, height, {
		card.big(data.busy and card.percent(data.busy) or "--"),
		card.note(table.concat(detail, " · ")),
		card.meter((data.busy or 0) / 100),
	})
end

return {
	id = "gpu",
	label = "GPU",
	icon = "gpu",
	width = 300,
	height = 140,
	view = gpu,
}
