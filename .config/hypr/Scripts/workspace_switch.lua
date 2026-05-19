local n = tonumber(arg[1])
local action = arg[2] or "focus"

local f = io.popen("hyprctl activeworkspace")
local out = f:read("*a")
f:close()

local mon = out:match("on monitor ([%w-]+)")
if mon == "DP-2" then n = n + 10 end

local dsp = (action == "focus") and "hl.dsp.focus" or "hl.dsp.window.move"
local cmd = "hyprctl dispatch '" .. dsp .. "({ workspace = \"" .. n .. "\" })'"
os.execute(cmd)
