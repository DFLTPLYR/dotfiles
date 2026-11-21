-- Screenshot capture. Bind `riced ipc screenshot` or press the button.
local plugin = riced.plugin("screenshot")
local screenshot = {}

function screenshot.capture(app, output)
	if not plugin.alive then
		app.screenshot_error = "screenshot extension offline"
		return
	end
	if plugin.capturing then
		return
	end -- one capture at a time
	local path = "~/Pictures/Screenshots/" .. os.date("%Y%m%d-%H%M%S") .. ".png"
	plugin.capture(output, path, function(_, err)
		app.screenshot_error = err
		if err then
			log(err)
		end
	end)
end

return screenshot
