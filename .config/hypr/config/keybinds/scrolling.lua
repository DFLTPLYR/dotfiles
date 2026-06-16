---------------------
----  SCROLLING  ----
---------------------

local mainMod = "SUPER" -- Sets "Windows" key as main modifier
local logfile = "/tmp/hypr/tmp.log"

hl.bind(mainMod .. " + SHIFT + D", function()
	local f = io.open(logfile, "r")
	if f then
		f:close()
		os.remove(logfile)
	else
		io.open(logfile, "w"):close()
	end
end)

local function log(msg)
	local f = io.open(logfile, "a")
	if f then
		f:write(os.date("%H:%M:%S") .. " " .. msg .. "\n")
		f:close()
	end
end
-- moving between
hl.bind(mainMod .. " + CTRL + L", hl.dsp.window.swap({ direction = "r" }))
hl.bind(mainMod .. " + CTRL + H", hl.dsp.window.swap({ direction = "l" }))
hl.bind(mainMod .. " + CTRL + K", hl.dsp.window.swap({ direction = "u" }))
hl.bind(mainMod .. " + CTRL + J", hl.dsp.window.swap({ direction = "d" }))

-- navigation

local function is_vertical(mon)
	return mon and (mon.transform == 3 or mon.transform == 4)
end

local function scroll(func, ...)
	local args = { ... }
	return function()
		return func(table.unpack(args))
	end
end

local function get_closest_monitor(dir, mon)
	local monitors = hl.get_monitors()
	local closest

	if dir == "left" then
		for _, m in ipairs(monitors) do
			if m.x + m.width == mon.x then
				closest = m
				break
			end
		end
	elseif dir == "right" then
		for _, m in ipairs(monitors) do
			if m.x == mon.x + mon.width then
				closest = m
				break
			end
		end
	elseif dir == "up" then
		for _, m in ipairs(monitors) do
			if m.y + m.height == mon.y then
				closest = m
				break
			end
		end
	elseif dir == "down" then
		for _, m in ipairs(monitors) do
			if m.y == mon.y + mon.height then
				closest = m
				break
			end
		end
	end
	return closest
end

local function get_sorted_windows(clients)
	local sorted = {}

	for _, c in ipairs(clients) do
		if not c.floating then
			table.insert(sorted, c)
		end
	end

	table.sort(sorted, function(a, b)
		return a.at.y < b.at.y
	end)

	return sorted
end

local function nav(dir)
	local mon = hl.get_active_monitor()
	local ws = hl.get_active_workspace()
	local cur = hl.get_active_window()

	if not mon or not ws then
		return hl.dispatch(hl.dsp.no_op())
	end

	local closemonitor = get_closest_monitor(dir, mon)
	local vertical = is_vertical(mon)
	local clients = hl.get_workspace_windows(ws.name)

	if not clients or #clients == 0 then
		if dir == "down" then
			return hl.dispatch(hl.dsp.no_op())
		elseif dir == "up" then
			return hl.dispatch(hl.dsp.focus({ workspace = "-1" }))
		else
			return hl.dispatch(hl.dsp.focus({ direction = dir }))
		end
	end

	local sorted = get_sorted_windows(clients)

	local wsz = hl.get_workspaces()
	local mon_wsz = {}

	for _, w in ipairs(wsz) do
		if w.monitor == mon then
			table.insert(mon_wsz, w)
		end
	end

	table.sort(mon_wsz, function(a, b)
		return a.id < b.id
	end)

	local firstws = mon_wsz[1].id == ws.id
	local lastws = mon_wsz[#mon_wsz].id == ws.id
	local isfirstwindow = cur.address == sorted[1].address
	local islastwindow = cur.address == sorted[#sorted].address

	if vertical then
		if dir == "left" or dir == "right" then
			if not closemonitor then
				return hl.dispatch(hl.dsp.no_op())
			end
			return hl.dispatch(hl.dsp.focus({ direction = dir }))
		end

		if cur.floating then
			if dir == "up" then
				return hl.dispatch(hl.dsp.focus({ window = sorted[1] }))
			elseif dir == "down" then
				return hl.dispatch(hl.dsp.focus({ window = sorted[#sorted] }))
			end
		end

		if firstws then
			if dir == "up" and isfirstwindow then
				return hl.dispatch(hl.dsp.no_op())
			elseif dir == "down" and islastwindow then
				return hl.dispatch(hl.dsp.focus({ workspace = "+1" }))
			end
			return hl.dispatch(hl.dsp.focus({ direction = dir }))
		elseif lastws then
			if dir == "up" and isfirstwindow then
				return hl.dispatch(hl.dsp.focus({ workspace = "m-1" }))
			elseif dir == "down" and islastwindow then
				return hl.dispatch(hl.dsp.focus({ workspace = "+1" }))
			end
			return hl.dispatch(hl.dsp.focus({ direction = dir }))
		else
			if dir == "up" and isfirstwindow then
				return hl.dispatch(hl.dsp.focus({ workspace = "m-1" }))
			elseif dir == "down" and islastwindow then
				return hl.dispatch(hl.dsp.focus({ workspace = "m+1" }))
			end
			return hl.dispatch(hl.dsp.focus({ direction = dir }))
		end
	else -- horizontal
		if dir == "left" or dir == "right" and (islastwindow or isfirstwindow) then
			return hl.dispatch(hl.dsp.focus({ direction = dir }))
		end

		if cur.floating then
			if dir == "left" then
				return hl.dispatch(hl.dsp.focus({ window = sorted[1] }))
			elseif dir == "right" then
				return hl.dispatch(hl.dsp.focus({ window = sorted[#sorted] }))
			end
		end

		if firstws then
			if dir == "up" then
				return hl.dispatch(hl.dsp.no_op())
			elseif dir == "down" then
				return hl.dispatch(hl.dsp.focus({ workspace = "+1" }))
			end
			return hl.dispatch(hl.dsp.focus({ direction = dir }))
		elseif lastws then
			if dir == "up" then
				return hl.dispatch(hl.dsp.focus({ workspace = "m-1" }))
			elseif dir == "down" then
				return hl.dispatch(hl.dsp.focus({ workspace = "+1" }))
			end
		else
			if dir == "up" then
				return hl.dispatch(hl.dsp.focus({ workspace = "m-1" }))
			elseif dir == "down" then
				return hl.dispatch(hl.dsp.focus({ workspace = "m+1" }))
			end
			return hl.dispatch(hl.dsp.focus({ direction = dir }))
		end
	end
end

hl.bind(mainMod .. " + left", scroll(nav, "left"))
hl.bind(mainMod .. " + right", scroll(nav, "right"))
hl.bind(mainMod .. " + up", scroll(nav, "up"))
hl.bind(mainMod .. " + down", scroll(nav, "down"))
hl.bind(mainMod .. " + H", scroll(nav, "left"))
hl.bind(mainMod .. " + L", scroll(nav, "right"))
hl.bind(mainMod .. " + K", scroll(nav, "up"))
hl.bind(mainMod .. " + J", scroll(nav, "down"))

hl.bind(mainMod .. " + mouse_up", scroll(nav, "down"))
hl.bind(mainMod .. " + mouse_down", scroll(nav, "up"))
