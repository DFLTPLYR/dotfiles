---------------------
---- KEYBINDINGS ----
---------------------
require(".config.keybinds.scrolling")

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

-- Toggle fullscreen
hl.bind(mainMod .. " + F", hl.dsp.window.fullscreen({ mode = "fullscreen", action = "toggle" }))
hl.bind(mainMod .. "+ SHIFT + F", hl.dsp.window.fullscreen({ mode = "maximized", action = "toggle" }))

-- Move/resize windows with mainMod + LMB/RMB and dragging
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- hl.on("workspace.active", function(ws)
-- log(ws.name)
-- end)

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
