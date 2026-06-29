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

hl.bind("SUPER + F11", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.1-"))
hl.bind("SUPER + F12", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.1+ -l 1.0"))
