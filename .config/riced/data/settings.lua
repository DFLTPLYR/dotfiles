-- Persistent settings + dock actions (data/settings.json).
-- Usage:
--   local settings = require("data.settings")
--   settings.addDock({ id = "term" })
--   settings.UpdateDock({ id = "term", pos = "bottom" })
--   settings.removeDock("term")

local defaults = {
	theme = "dark",
	docks = {},
	background = "/home/dfltplyr/Pictures/Wallpaper/cats.png",
	outputs = {},
}

-- Tables are shared with defaults otherwise, so give each file its own copy.
local function copy_defaults()
	local copy = {}
	for key, value in pairs(defaults) do
		copy[key] = type(value) == "table" and {} or value
	end
	return copy
end

local settings = riced.file({
	path = "data/settings.json",
	onLoaded = function(file, data)
		if type(data) ~= "table" or next(data) == nil then
			file.data = copy_defaults()
			local ok, err = file:write()
			if not ok then
				print(err)
			end
		end
	end,
	onError = function(file, err)
		print(err)
	end,
})

-- onError runs before `settings` exists, so repair bad/partial data here.
local function valid(data)
	if type(data) ~= "table" then
		return false
	end
	for key, default in pairs(defaults) do
		if type(data[key]) ~= type(default) then
			return false
		end
	end
	return true
end

if not valid(settings.data) then
	local previous = type(settings.data) == "table" and settings.data or {}
	local repaired = copy_defaults()
	for key, default in pairs(defaults) do
		if type(previous[key]) == type(default) then
			repaired[key] = previous[key]
		end
	end
	settings.data = repaired
	local ok, err = settings:write()
	if not ok then
		print(err)
	end
end

local function save_docks(docks)
	local data = settings.data
	data.docks = docks
	settings.data = data
	return settings:write()
end

local function find_dock(docks, id)
	for i, dock in ipairs(docks) do
		if dock.id == id then
			return i
		end
	end
	return nil
end

local function addDock(dock)
	if type(dock) ~= "table" or type(dock.id) ~= "string" or dock.id == "" then
		return false, "dock must have a non-empty string id"
	end
	local docks = settings.data.docks
	if find_dock(docks, dock.id) then
		return false, "dock already exists: " .. dock.id
	end
	docks[#docks + 1] = dock
	return save_docks(docks)
end

local function removeDock(id)
	if type(id) ~= "string" or id == "" then
		return false, "dock id must be a non-empty string"
	end
	local docks = settings.data.docks
	local index = find_dock(docks, id)
	if not index then
		return false, "dock not found: " .. id
	end
	table.remove(docks, index)
	return save_docks(docks)
end

local function UpdateDock(dock)
	if type(dock) ~= "table" or type(dock.id) ~= "string" or dock.id == "" then
		return false, "dock must have a non-empty string id"
	end
	local docks = settings.data.docks
	local index = find_dock(docks, dock.id)
	if not index then
		return false, "dock not found: " .. dock.id
	end
	docks[index] = dock
	return save_docks(docks)
end

return {
	file = settings,
	addDock = addDock,
	removeDock = removeDock,
	UpdateDock = UpdateDock,
}
