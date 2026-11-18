iced.define("clock", function()
	local widget = {}

	function widget:view(content, props)
		local system = riced.plugins("system")
		local function clock(format)
			local time = system.time
			return time and time.epoch and os.date(format, time.epoch) or "--:--"
		end

		return iced.text(clock(content.format), props)
	end

	return widget
end)
