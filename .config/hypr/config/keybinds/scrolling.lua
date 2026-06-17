---------------------
----  SCROLLING  ----
---------------------

local mainMod = "SUPER"
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

local function scroll(func, ...)
	local args = { ... }
	return function()
		return func(table.unpack(args))
	end
end

local function is_vertical(mon)
	return mon and (mon.transform == 3 or mon.transform == 4)
end

local function get_props()
	local mon = hl.get_active_monitor()
	local ws = hl.get_active_workspace()
	local cur = hl.get_active_window()
	return mon, ws, cur
end

local function get_workspace_position(mon_wsz, ws)
	if not mon_wsz or not ws then
		return false, false
	end
	return mon_wsz[1].id == ws.id, mon_wsz[#mon_wsz].id == ws.id
end

local function get_window_position(cur, sorted)
	if not cur or not sorted then
		return false, false
	end
	return cur.address == sorted[1].address, cur.address == sorted[#sorted].address
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

local function get_available_workspace(mon)
	local wsz = hl.get_workspaces()
	local available = {}

	for _, w in ipairs(wsz) do
		if w.monitor == mon then
			table.insert(available, w)
		end
	end

	table.sort(available, function(a, b)
		return a.id < b.id
	end)
	return available
end

local function get_sorted_windows(clients, sort_by_x)
	local sorted = {}

	for _, c in ipairs(clients) do
		if not c.floating then
			table.insert(sorted, c)
		end
	end

	table.sort(sorted, function(a, b)
		if sort_by_x then
			return a.at.x < b.at.x
		else
			return a.at.y < b.at.y
		end
	end)

	return sorted
end

-- navigation

local function vertical(cur, dir, clients, mon, ws, closemonitor)
	if not cur then
		if dir == "up" or dir == "down" then
			return hl.dispatch(hl.dsp.focus({ workspace = "m-1" }))
		end
		return hl.dispatch(hl.dsp.focus({ direction = dir }))
	end

	if not clients or #clients == 0 then
		if dir == "down" then
			return hl.dispatch(hl.dsp.focus({ last = true }))
		elseif dir == "up" then
			return hl.dispatch(hl.dsp.focus({ workspace = "-1" }))
		else
			return hl.dispatch(hl.dsp.focus({ direction = dir }))
		end
	end

	local sorted = get_sorted_windows(clients)
	local mon_wsz = get_available_workspace(mon)
	local firstws, lastws = get_workspace_position(mon_wsz, ws)
	local isfirstwindow, islastwindow = get_window_position(cur, sorted)

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
			if #mon_wsz == 1 then
				return hl.dispatch(hl.dsp.focus({ workspace = "+1" }))
			end
			return hl.dispatch(hl.dsp.focus({ workspace = "m+1" }))
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
end

local function horizontal(cur, dir, clients, mon, ws, closemonitor)
	if not cur then
		if dir == "up" or dir == "down" then
			return hl.dispatch(hl.dsp.focus({ workspace = "m-1" }))
		end
		return hl.dispatch(hl.dsp.focus({ direction = dir }))
	end

	if not clients or #clients == 0 then
		if dir == "down" then
			return hl.dispatch(hl.dsp.no_op())
		elseif dir == "up" then
			return hl.dispatch(hl.dsp.focus({ workspace = "-1" }))
		else
			return hl.dispatch(hl.dsp.focus({ direction = dir }))
		end
	end

	local sorted = get_sorted_windows(clients, true)
	local mon_wsz = get_available_workspace(mon)
	local firstws, lastws = get_workspace_position(mon_wsz, ws)
	local isfirstwindow, islastwindow = get_window_position(cur, sorted)

	if (dir == "left" or dir == "right") and (islastwindow or isfirstwindow) then
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
			if #mon_wsz == 1 then
				return hl.dispatch(hl.dsp.focus({ workspace = "+1" }))
			end
			return hl.dispatch(hl.dsp.focus({ workspace = "m+1" }))
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

local function nav(dir)
	if type(dir) == "number" then
		if dir == -1 then
			return hl.dispatch(hl.dsp.focus({ workspace = "m-1" }))
		elseif dir == 1 then
			return hl.dispatch(hl.dsp.focus({ workspace = "m+1" }))
		end
	end

	local mon, ws, cur = get_props()

	if not mon or not ws then
		return hl.dispatch(hl.dsp.no_op())
	end

	local closemonitor = get_closest_monitor(dir, mon)
	local clients = hl.get_workspace_windows(ws.name)

	if is_vertical(mon) then
		return vertical(cur, dir, clients, mon, ws, closemonitor)
	else -- horizontal
		return horizontal(cur, dir, clients, mon, ws, closemonitor)
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
hl.bind(mainMod .. " + SHIFT + mouse_up", scroll(nav, -1))
hl.bind(mainMod .. " + SHIFT + mouse_down", scroll(nav, 1))

local function workspace_jump(dir)
	local mon, ws, cur = get_props()

	if not mon or not ws then
		return hl.dispatch(hl.dsp.no_op())
	end

	local mon_wsz = get_available_workspace(mon)
	local firstws, lastws = get_workspace_position(mon_wsz, ws)

	-- if is_vertical(mon) then
	if dir == "left" or dir == "right" then
		return hl.dispatch(hl.dsp.no_op())
	end
	if dir == "up" then
		if firstws then
			return hl.dispatch(hl.dsp.no_op())
		end
		return hl.dispatch(hl.dsp.focus({ workspace = "m-1", on_current_monitor = true }))
	elseif dir == "down" then
		if lastws then
			if cur then
				return hl.dispatch(hl.dsp.focus({ workspace = "+1", on_current_monitor = true }))
			end
			return hl.dispatch(hl.dsp.no_op())
		end
		return hl.dispatch(hl.dsp.focus({ workspace = "m+1", on_current_monitor = true }))
	end
	-- else -- horizontal
	-- 	if dir == "left" or dir == "right" then
	-- 		return
	-- 	end
	-- end
end

-- focus next workspace
hl.bind(mainMod .. "+ SHIFT + K", scroll(workspace_jump, "up"))
hl.bind(mainMod .. "+ SHIFT + J", scroll(workspace_jump, "down"))

-- Move focus to monitor
hl.bind(mainMod .. "+ SHIFT + H", hl.dsp.focus({ monitor = "l" }))
hl.bind(mainMod .. "+ SHIFT + L", hl.dsp.focus({ monitor = "r" }))

-- swapping
local function swap(dir)
	local mon, ws, cur = get_props()

	if not mon or not ws or not cur then
		return hl.dispatch(hl.dsp.no_op())
	end

	local vertical = is_vertical(mon)
	local monitor = get_closest_monitor(dir, mon)
	local clients = hl.get_workspace_windows(ws.name)

	if not clients or #clients == 0 then
		return hl.dispatch(hl.dsp.no_op())
	end

	if cur and cur.floating then
		return hl.dispatch(hl.dsp.no_op())
	end

	local mon_wsz = get_available_workspace(mon)
	local closemonitor = get_closest_monitor(dir, mon)
	local firstws, lastws = get_workspace_position(mon_wsz, ws)

	if is_vertical(mon) then
		local sorted = get_sorted_windows(clients)
		local isfirstwindow, islastwindow = get_window_position(cur, sorted)

		if dir == "up" then
			if isfirstwindow then
				if closemonitor then
					return hl.dispatch(hl.dsp.window.move({ direction = dir }))
				elseif not firstws then
					return hl.dispatch(hl.dsp.window.move({ workspace = "m-1" }))
				end
			else
				return hl.dispatch(hl.dsp.window.swap({ direction = dir }))
			end
		elseif dir == "down" then
			if islastwindow then
				if closemonitor then
					return hl.dispatch(hl.dsp.window.move({ direction = dir }))
				elseif not lastws then
					return hl.dispatch(hl.dsp.window.move({ workspace = "m+1" }))
				elseif lastws and #sorted ~= 1 then
					return hl.dispatch(hl.dsp.window.move({ workspace = "+1" }))
				end
			else
				return hl.dispatch(hl.dsp.window.swap({ direction = dir }))
			end
		elseif dir == "left" then
			if closemonitor then
				return hl.dispatch(hl.dsp.window.move({ direction = dir }))
			end
		elseif dir == "right" then
			if closemonitor then
				return hl.dispatch(hl.dsp.window.move({ direction = dir }))
			end
		end
	else
		local sorted = get_sorted_windows(clients, true)
		local isfirstwindow, islastwindow = get_window_position(cur, sorted)

		if dir == "up" then
			if closemonitor then
				return hl.dispatch(hl.dsp.window.move({ direction = dir }))
			elseif not firstws then
				return hl.dispatch(hl.dsp.window.move({ workspace = "m-1" }))
			end
		elseif dir == "down" then
			if closemonitor then
				return hl.dispatch(hl.dsp.window.move({ direction = dir }))
			elseif lastws and #mon_wsz == 1 and #sorted ~= 1 then
				return hl.dispatch(hl.dsp.window.move({ workspace = "+1" }))
			else
				return hl.dispatch(hl.dsp.window.move({ workspace = "m+1" }))
			end
		elseif dir == "left" then
			if isfirstwindow and closemonitor then
				return hl.dispatch(hl.dsp.window.move({ direction = dir }))
			end
			return hl.dispatch(hl.dsp.window.swap({ direction = dir }))
		elseif dir == "right" then
			if islastwindow and closemonitor then
				return hl.dispatch(hl.dsp.window.move({ direction = dir }))
			end
			return hl.dispatch(hl.dsp.window.swap({ direction = dir }))
		end
	end

	return hl.dispatch(hl.dsp.no_op())
end

hl.bind(mainMod .. " + CTRL + L", scroll(swap, "right"))
hl.bind(mainMod .. " + CTRL + H", scroll(swap, "left"))
hl.bind(mainMod .. " + CTRL + K", scroll(swap, "up"))
hl.bind(mainMod .. " + CTRL + J", scroll(swap, "down"))

local function go_to_ws(n, action)
	if not n then
		return
	end
	n = tonumber(n)
	if not n then
		return
	end
	local mon, ws, cur = get_props()
	local wsz = hl.get_workspaces()

	if not mon or not wsz then
		return
	end

	local mon_wsz = {}

	for _, w in ipairs(wsz) do
		if w.monitor == mon then
			table.insert(mon_wsz, w)
		end
	end

	table.sort(mon_wsz, function(a, b)
		return a.id < b.id
	end)

	local ws_id
	if n <= #mon_wsz then
		ws_id = mon_wsz[n].id
	else
		if not cur then
			return hl.dispatch(hl.dsp.no_op())
		end
		ws_id = mon_wsz[#mon_wsz].id + 1
	end
	hl.dispatch(hl.dsp.focus({ workspace = tostring(ws_id), on_current_monitor = true }))
end

for i = 1, 9 do
	hl.bind(mainMod .. " + " .. i, scroll(go_to_ws, i, "focus"))
end
