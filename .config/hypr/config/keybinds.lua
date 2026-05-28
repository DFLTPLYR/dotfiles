---------------------
---- KEYBINDINGS ----
---------------------
local mainMod = "SUPER" -- Sets "Windows" key as main modifier

hl.bind(mainMod .. " + T", hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + Q", hl.dsp.window.close())
hl.bind(mainMod .. " + P", hl.dsp.exec_cmd([[grim -g "$(slurp)" - | wl-copy]]))
hl.bind(mainMod .. "+ SHIFT + P", hl.dsp.exec_cmd([[grim -g "$(slurp -o)" - | wl-copy]]))
-- hl.bind(mainMod .. " + F", hl.dsp.window.focus({ fullscreen = true }))

hl.bind(mainMod .. " + E", hl.dsp.exec_cmd(fileManager))
hl.bind(mainMod .. " + B", hl.dsp.exec_cmd(browser))
hl.bind(mainMod .. " + A", hl.dsp.exec_cmd(menu))
hl.bind(mainMod .. " + S", hl.dsp.exec_cmd(mode))
hl.bind(mainMod .. "+ DELETE", hl.dsp.exec_cmd("pkill -x qs"))

hl.bind(mainMod .. " + V", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + P", hl.dsp.window.pseudo())

-- Move focus/workspace with mainMod + direction keys
-- On horizontal-scrolling monitors (DP-1), up/down switches workspace
-- left/right always focuses direction (Hyprland falls through to next monitor at edge)
local function is_horizontal()
	local mon = hl.get_active_monitor()
	return mon and mon.name == "DP-1"
end

local function nav(ws, dir)
	return function()
		if is_horizontal() then
			hl.dispatch(hl.dsp.focus(ws))
		else
			local before = hl.get_active_window()
			local addr = before and before.address
			hl.dispatch(hl.dsp.focus({ direction = dir }))
			local after = hl.get_active_window()
			if (not before and not after) or (addr and after and after.address == addr) then
				hl.dispatch(hl.dsp.focus(ws))
			end
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

-- Move focus to monitor with mainMod + direction keys
-- hl.bind(mainMod .. " + left", hl.dsp.focus({ monitor = "left" }))
-- hl.bind(mainMod .. " + right", hl.dsp.focus({ monitor = "right" }))
-- hl.bind(mainMod .. " + up", hl.dsp.focus({ monitor = "up" }))
-- hl.bind(mainMod .. " + down", hl.dsp.focus({ monitor = "down" }))
hl.bind(mainMod .. "+ SHIFT + H", hl.dsp.focus({ monitor = "l" }))
hl.bind(mainMod .. "+ SHIFT + L", hl.dsp.focus({ monitor = "r" }))
hl.bind(mainMod .. "+ SHIFT + K", hl.dsp.focus({ monitor = "u" }))
hl.bind(mainMod .. "+ SHIFT + J", hl.dsp.focus({ monitor = "d" }))

-- Toggle fullscreen
hl.bind(mainMod .. " + F", hl.dsp.window.fullscreen({ mode = "fullscreen", action = "toggle" }))
hl.bind(mainMod .. "+ SHIFT + F", hl.dsp.window.fullscreen({ mode = "maximized", action = "toggle" }))

-- Move/resize windows with mainMod + LMB/RMB and dragging
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Workspace switching: 1-9 -> N on current monitor (N+10 on DP-2)
local function ws_switch(n, action)
	if not n then
		return
	end
	n = tonumber(n)
	if not n then
		return
	end

	local mon = hl.get_active_monitor()
	if mon and mon.name == "DP-2" then
		n = n + 100
	end

	if action == "focus" then
		hl.dispatch(hl.dsp.focus({ workspace = tostring(n) }))
	else
		hl.dispatch(hl.dsp.window.move({ workspace = tostring(n) }))
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

hl.bind(mainMod .. " + mouse_down", function()
	if is_horizontal() then
		hl.dispatch(hl.dsp.focus({ workspace = "+1" }))
	else
		hl.dispatch(hl.dsp.focus({ workspace = "e+1" }))
	end
end)
hl.bind(mainMod .. " + mouse_up", hl.dsp.focus({ workspace = "e-1" }))
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
