-- Screenshot widget. Bind `riced ipc screenshot` or press the button.
local plugin = riced.plugin("screenshot")
local screenshot = {}

local function capture(app, output)
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
	end)
end

function screenshot.capture(app, output)
	capture(app, output)
end

function screenshot.update(app, event)
	if event == "screenshot" then
		capture(app, nil) -- nil = first output
	end
end

function screenshot.view()
	if not plugin.alive then
		return iced.text("screenshot extension offline", { color = theme.secondary })
	end
	-- Re-read store every view: each publish replaces the snapshot.
	local last = plugin.last
	local caption = plugin.capturing and "capturing…"
		or last and string.format("saved %s (%d KiB)", last.output, last.bytes // 1024)
		or "no capture yet"
	local preview = last and iced.image(last.path, { content_fit = "cover" })
		or iced.space(nil, { width = 160, height = 90 })
	return iced.column({
		iced.button("capture", { on_press = "screenshot" }),
		preview,
		iced.text(caption, { color = theme.secondary }),
	}, { spacing = 4 })
end

return screenshot
