---------------------
---- KEYBINDINGS ----
---------------------

local mainMod = "SUPER" -- Sets "Windows" key as main modifier
local logfile = "/tmp/hypr/tmp.log"

local function log(msg)
	local f = io.open(logfile, "a")
	if f then
		f:write(os.date("%H:%M:%S") .. " " .. msg .. "\n")
		f:close()
	end
end

hl.bind(mainMod .. " + SHIFT + D", function()
	local f = io.open(logfile, "r")
	if f then
		f:close()
		os.remove(logfile)
		log("debug: off")
		hl.dsp.exec_cmd("notify-send 'Debug' 'off'")
	else
		io.open(logfile, "w"):close()
		log("debug: on")
		hl.dsp.exec_cmd("notify-send 'Debug' 'on'")
	end
end)

local function log(msg)
	local f = io.open(logfile, "a")
	if f then
		f:write(os.date("%H:%M:%S") .. " " .. msg .. "\n")
		f:close()
	end
end

hl.bind(mainMod .. " + T", hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + Q", hl.dsp.window.close())
hl.bind(mainMod .. " + P", hl.dsp.exec_cmd(selectshot))
hl.bind(mainMod .. " + SHIFT + P", hl.dsp.exec_cmd(screenshot))
-- hl.bind(mainMod .. " + F", hl.dsp.window.focus({ fullscreen = true }))

hl.bind(mainMod .. " + E", hl.dsp.exec_cmd(filemanager))
hl.bind(mainMod .. " + B", hl.dsp.exec_cmd(browser))
hl.bind(mainMod .. " + A", hl.dsp.exec_cmd(menu))
hl.bind(mainMod .. " + S", hl.dsp.exec_cmd(mode))
hl.bind(mainMod .. " + C", hl.dsp.exec_cmd(clipboard))
hl.bind(mainMod .. " + DELETE", hl.dsp.exec_cmd("pkill -f quickshell"))

hl.bind(mainMod .. " + V", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + P", hl.dsp.window.pseudo())

local function is_vertical(mon)
	return mon and (mon.transform == 3 or mon.transform == 4)
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

local function get_sorted_workspace(clients)
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
	return function()
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

		local sorted = get_sorted_workspace(clients)

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
			end
		end
	end
end

hl.bind(mainMod .. " + left", nav("left"))
hl.bind(mainMod .. " + right", nav("right"))
hl.bind(mainMod .. " + up", nav("up"))
hl.bind(mainMod .. " + down", nav("down"))
hl.bind(mainMod .. " + H", nav("left"))
hl.bind(mainMod .. " + L", nav("right"))
hl.bind(mainMod .. " + K", nav("up"))
hl.bind(mainMod .. " + J", nav("down"))

-- focus next workspace
hl.bind(mainMod .. "+ SHIFT + K", hl.dsp.focus({ workspace = "m-1", on_current_monitor = true }))
hl.bind(mainMod .. "+ SHIFT + J", hl.dsp.focus({ workspace = "+1", on_current_monitor = true }))

-- Move focus to monitor
hl.bind(mainMod .. "+ SHIFT + H", hl.dsp.focus({ monitor = "l" }))
hl.bind(mainMod .. "+ SHIFT + L", hl.dsp.focus({ monitor = "r" }))

-- Toggle fullscreen
hl.bind(mainMod .. " + F", hl.dsp.window.fullscreen({ mode = "fullscreen", action = "toggle" }))
hl.bind(mainMod .. "+ SHIFT + F", hl.dsp.window.fullscreen({ mode = "maximized", action = "toggle" }))

-- Move/resize windows with mainMod + LMB/RMB and dragging
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

hl.on("workspace.active", function(ws)
	-- log(ws.name)
end)

-- hl.on("workspace.removed", function()
-- 	local wsz = hl.get_workspaces()
-- 	if not wsz then
-- 		return
-- 	end
--
-- 	local mon_wsz = {}
-- 	for _, w in ipairs(wsz) do
-- 		local mon = w.monitor
-- 		if mon then
-- 			if not mon_wsz[mon] then
-- 				mon_wsz[mon] = {}
-- 			end
-- 			table.insert(mon_wsz[mon], w)
-- 		end
-- 	end
--
-- 	for _, workspaces in pairs(mon_wsz) do
-- 		table.sort(workspaces, function(a, b)
-- 			return a.id < b.id
-- 		end)
--
-- 		local min_id = workspaces[1].id
-- 		local base = math.floor(min_id / 100) * 100
--
-- 		for i, w in ipairs(workspaces) do
-- 			local expected = base + i
-- 			if w.id ~= expected then
-- 				hl.dispatch("renameworkspace " .. w.id .. " " .. expected)
-- 			end
-- 		end
-- 	end
-- end)

local function go_to_ws(n, action)
	if not n then
		return
	end
	n = tonumber(n)
	if not n then
		return
	end

	local mon = hl.get_active_monitor()
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
		local cur = hl.get_active_window()
		if not cur then
			return hl.dispatch(hl.dsp.no_op())
		end
		ws_id = mon_wsz[#mon_wsz].id + 1
	end
	hl.dispatch(hl.dsp.focus({ workspace = tostring(ws_id), on_current_monitor = true }))
end

for i = 1, 9 do
	hl.bind(mainMod .. " + " .. i, function()
		go_to_ws(i, "focus")
	end)
end

hl.bind(mainMod .. " + mouse_up", nav("down"))
hl.bind(mainMod .. " + mouse_down", nav("up"))

hl.bind("SUPER + Tab", function()
	hl.dispatch(hl.dsp.window.cycle_next()) -- Change focus to another window
	hl.dispatch(hl.dsp.window.bring_to_top()) -- Bring it to the top
end)

hl.bind(mainMod .. "+ equal", hl.dsp.layout("colresize +0.2"))
hl.bind(mainMod .. "+ minus", hl.dsp.layout("colresize -0.2"))
hl.bind(mainMod .. "+ SHIFT + comma", hl.dsp.layout("consume_or_expel prev"))
hl.bind(mainMod .. "+ SHIFT + period", hl.dsp.layout("consume_or_expel next"))
hl.bind(mainMod .. "+ comma", hl.dsp.layout("swapcol l"))
hl.bind(mainMod .. "+ period", hl.dsp.layout("swapcol r"))

hl.bind("SUPER + F11", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.1+ -l 1.0"))
hl.bind("SUPER + F12", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.1-"))
