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

local function is_vertical()
	local mon = hl.get_active_monitor()
	return mon and (mon.transform == 3 or mon.transform == 4)
end

local function monitor_index(name)
	local monitors = hl.get_monitors()
	table.sort(monitors, function(a, b)
		return a.id < b.id
	end)
	for i, mon in ipairs(monitors) do
		if mon.name == name then
			return i
		end
	end
	return 1
end

local function nav(ws, dir)
	return function()
		local mon = hl.get_active_monitor()
		local vertical = is_vertical()
		if not mon then
			return
		end
		local ws = hl.get_active_workspace()

		local clients = hl.get_workspace_windows(ws.name)
		local cur = hl.get_active_window()
		if not cur or not clients or #clients == 0 then
			return
		end

		local sorted = {}
		for _, c in ipairs(clients) do
			table.insert(sorted, c)
		end
		table.sort(sorted, function(a, b)
			return a.at.y < b.at.y
		end)

		if vertical then
			if cur.address == sorted[1].address and dir == "up" then
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
				if ws.id == mon_wsz[1].id then
					return hl.dispatch(hl.dsp.no_op())
				end
			end
			hl.dispatch(hl.dsp.focus({ direction = dir }))
		else -- horizontal
			if dir ~= "up" and dir ~= "down" then
				hl.dispatch(hl.dsp.focus({ direction = dir }))
			else
				log(tostring(ws) .. " testing ")
				-- hl.dispatch(hl.dsp.focus({ workspace = tostring(mon_wsz[cur_idx - 1].id), on_current_monitor = true }))
			end
			return
		end
	end
end

hl.bind(mainMod .. " + left", hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + up", nav({ workspace = "m-1" }, "up"))
hl.bind(mainMod .. " + down", nav({ workspace = "+1" }, "down"))
hl.bind(mainMod .. " + H", hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + L", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + K", nav({ workspace = "m-1" }, "up"))
hl.bind(mainMod .. " + J", nav({ workspace = "+1" }, "down"))

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

local function ws_switch(n, action)
	if not n then
		return
	end
	n = tonumber(n)
	if not n then
		return
	end

	local mon = hl.get_active_monitor()
	if not mon then
		return
	end

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

	local ws_id
	if n <= #mon_wsz then
		ws_id = mon_wsz[n].id
	else
		ws_id = n + (monitor_index(mon.name) - 1) * 100

		log(ws_id)
	end

	if action == "focus" then
		hl.dispatch(hl.dsp.focus({ workspace = tostring(ws_id), on_current_monitor = true }))
	else
		-- hl.dispatch(hl.dsp.window.move({ workspace = tostring(ws_id), on_current_monitor = true }))
	end
end

for i = 1, 9 do
	hl.bind(mainMod .. " + " .. i, function()
		ws_switch(i, "focus")
	end)
	hl.bind(mainMod .. " + SHIFT + " .. i, function()
		ws_switch(i, "movetoworkspace")
	end)
end

hl.bind(mainMod .. " + mouse_up", nav({ workspace = "m+1" }, "down"))
hl.bind(mainMod .. " + mouse_down", nav({ workspace = "m-1" }, "up"))

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
