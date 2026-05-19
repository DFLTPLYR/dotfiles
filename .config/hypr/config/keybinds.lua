---------------------
---- KEYBINDINGS ----
---------------------
local mainMod = "SUPER" -- Sets "Windows" key as main modifier

hl.bind(mainMod .. " + T", hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + Q", hl.dsp.window.close())
-- hl.bind(mainMod .. " + F", hl.dsp.window.focus({ fullscreen = true }))

hl.bind(mainMod .. " + E", hl.dsp.exec_cmd(fileManager))
hl.bind(mainMod .. " + B", hl.dsp.exec_cmd(browser))
hl.bind(mainMod .. " + A", hl.dsp.exec_cmd(menu))
hl.bind(mainMod .. " + S", hl.dsp.exec_cmd(mode))
hl.bind(mainMod .. "+ DELETE", hl.dsp.exec_cmd("pkill -x qs"))

hl.bind(mainMod .. " + V", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + P", hl.dsp.window.pseudo())

-- Move focus with mainMod + arrow keys
hl.bind(mainMod .. " + left", hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + up", hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + down", hl.dsp.focus({ direction = "down" }))
hl.bind(mainMod .. " + H", hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + L", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + K", hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + J", hl.dsp.focus({ direction = "down" }))

hl.bind(mainMod .. " + F", hl.dsp.window.fullscreen_state({ action = "toggle", internal = 0, client = 2 }))

-- Move/resize windows with mainMod + LMB/RMB and dragging
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Workspace switching: 1-9 -> N on current monitor (N+10 on DP-2)
local ws_switch = os.getenv("HOME") .. "/.config/hypr/Scripts/workspace_switch.lua"
for i = 1, 9 do
	hl.bind(mainMod .. " + " .. i, hl.dsp.exec_cmd("lua " .. ws_switch .. " " .. i))
	hl.bind(mainMod .. " + SHIFT + " .. i, hl.dsp.exec_cmd("lua " .. ws_switch .. " " .. i .. " movetoworkspace"))
end
hl.bind("SUPER + Tab", function()
	hl.dispatch(hl.dsp.window.cycle_next()) -- Change focus to another window
	hl.dispatch(hl.dsp.window.bring_to_top()) -- Bring it to the top
end)
hl.bind(mainMod .. "+ equal", hl.dsp.layout("colresize +0.2"))
hl.bind(mainMod .. "+ minus", hl.dsp.layout("colresize -0.2"))
hl.bind(mainMod .. "+ comma", hl.dsp.layout("consume"))
hl.bind(mainMod .. "+ period", hl.dsp.layout("expel"))
hl.bind(mainMod .. "+ SHIFT + comma", hl.dsp.layout("swapcol l"))
hl.bind(mainMod .. "+ SHIFT + period", hl.dsp.layout("swapcol r"))
