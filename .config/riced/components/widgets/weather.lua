-- Current weather from the openmeteo extension.

local card = require("components.widgets.card")
local openmeteo = require("extensions.openmeteo.openmeteo")

local WEATHER_LAT, WEATHER_LON = 14.082809573743582, 120.83566060057112
openmeteo.configure(WEATHER_LAT, WEATHER_LON)

-- WMO weather codes mapped to lucide icon names.
local function weather_icon(current)
	local code = current.weather_code or 0
	if code == 0 then
		return current.is_day == 0 and "moon" or "sun"
	elseif code <= 3 then
		return "cloud-sun"
	elseif code == 45 or code == 48 then
		return "cloud-fog"
	elseif code >= 51 and code <= 67 then
		return "cloud-rain"
	elseif code >= 71 and code <= 77 then
		return "cloud-snow"
	elseif code >= 80 and code <= 82 then
		return "cloud-rain-wind"
	elseif code >= 85 and code <= 86 then
		return "cloud-snow"
	elseif code >= 95 then
		return "cloud-lightning"
	end
	return "cloud"
end

local function weather(entry, width, height)
	local ext = openmeteo.plugin
	local current = ext.current or {}
	local temp = current.temperature_2m
	if not ext.alive then
		return card.card(entry, width, height, card.placeholder("Weather offline"), "cloud")
	end
	if type(temp) ~= "number" then
		return card.card(entry, width, height, card.placeholder(ext.error and "Weather unavailable" or "Loading weather…"), "cloud")
	end
	local detail = {}
	if current.relative_humidity_2m then
		detail[#detail + 1] = string.format("H %.0f%%", current.relative_humidity_2m)
	end
	if current.wind_speed_10m then
		detail[#detail + 1] = string.format("W %.0f km/h", current.wind_speed_10m)
	end
	return card.card(entry, width, height, {
		card.big(string.format("%.1f°C", temp)),
		card.note(table.concat(detail, " · ")),
	}, weather_icon(current))
end

return {
	id = "weather",
	label = "Weather",
	icon = "cloud-sun",
	width = 240,
	height = 120,
	view = weather,
}
