-- Screenshot capture. Bind `riced ipc screenshot` or press the button.
local plugin = riced.plugin("screenshot")
local screenshot = {}

function screenshot.capture(output)
	if not plugin.alive then
		return
	end
	if plugin.capturing then
		return
	end -- one capture at a time
	local path = "~/Pictures/Screenshots/" .. os.date("%Y%m%d-%H%M%S") .. ".png"
	plugin.capture(output, path, function(_, err)
		if err then
			log(err)
		end
	end)
end

return screenshot
