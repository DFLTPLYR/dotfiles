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

local function copy_defaults()
	return {
		theme = defaults.theme,
		docks = {},
		background = defaults.background,
		outputs = {},
	}
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
if
	type(settings.data) ~= "table"
	or type(settings.data.theme) ~= "string"
	or type(settings.data.docks) ~= "table"
	or type(settings.data.background) ~= "string"
	or type(settings.data.outputs) ~= "table"
then
	local repaired = copy_defaults()
	if type(settings.data) == "table" then
		if type(settings.data.theme) == "string" then
			repaired.theme = settings.data.theme
		end
		if type(settings.data.docks) == "table" then
			repaired.docks = settings.data.docks
		end
		if type(settings.data.background) == "string" then
			repaired.background = settings.data.background
		end
		if type(settings.data.outputs) == "table" then
			repaired.outputs = settings.data.outputs
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
