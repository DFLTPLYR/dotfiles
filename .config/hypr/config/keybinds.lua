local mainMod = "SUPER"
local scriptsDir = os.getenv("HOME") .. "/.config/hypr/Scripts"
local localScript = os.getenv("HOME") .. "/.local/bin"

hl.bind(mainMod .. " + Q", hl.dsp.window.close())
hl.bind(mainMod .. " + T", hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd(fileManager))
hl.bind(mainMod .. " + C", hl.dsp.exec_cmd(editor))
hl.bind(mainMod .. " + B", hl.dsp.exec_cmd(browser))

hl.bind(mainMod .. " + period", hl.dsp.layout("expel"))
hl.bind(mainMod .. " + comma", hl.dsp.layout("consume"))
-- hl.bind(mainMod .. " + period", hl.dsp.exec_cmd(scriptsDir .. "/EmojiRofi.sh"))
-- hl.bind(mainMod .. " + CTRL + S", hl.dsp.exec_cmd(scriptsDir .. "/ShowCaseMode.sh"))
hl.bind(mainMod .. " + P", hl.dsp.exec_cmd('grim -g "$(slurp)" - | satty -f - --copy-command wl-copy'))

hl.bind(mainMod .. " + W", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + F", hl.dsp.window.fullscreen())
hl.bind(mainMod .. " + D", hl.dsp.layout("togglesplit"))
-- hl.bind(mainMod .. " + G", hl.dsp.window.group.toggle())

hl.bind(mainMod .. " + H", hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + L", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + K", hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + J", hl.dsp.focus({ direction = "down" }))

hl.bind(mainMod .. " + SHIFT + H", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + SHIFT + L", hl.dsp.focus({ workspace = "e-1" }))

for i = 1, 10 do
	local key = i % 10
	hl.bind(mainMod .. " + " .. key, hl.dsp.focus({ workspace = i }))
	hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end

hl.bind(mainMod .. " + C", hl.dsp.workspace.toggle_special("magic"))
hl.bind(mainMod .. " + SHIFT + C", hl.dsp.window.move({ workspace = "special:magic" }))

hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + mouse_up", hl.dsp.focus({ direction = "right" }))

hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

hl.bind(mainMod .. " + minus", hl.dsp.layout("colresize -0.2"))
hl.bind(mainMod .. " + equal", hl.dsp.layout("colresize +0.2"))
hl.bind(mainMod .. " + period", hl.dsp.layout("move +col"))
hl.bind(mainMod .. " + comma", hl.dsp.layout("move -col"))

hl.bind(mainMod .. " + SHIFT + comma", hl.dsp.layout("swapcol l"))
hl.bind(mainMod .. " + SHIFT + period", hl.dsp.layout("swapcol r"))

hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), { locked = true })

hl.bind("F11", hl.dsp.exec_cmd(localScript .. "/volume-control.sh --dec"))
hl.bind("F12", hl.dsp.exec_cmd(localScript .. "/volume-control.sh --inc"))

hl.bind(mainMod .. " + A", hl.dsp.exec_cmd("pkill -x rofi || " .. menu), { description = "App Menu" })
hl.bind(mainMod .. " + S", hl.dsp.exec_cmd("pcli launch shell-settings"), { description = "Show Quickshell Settings" })
hl.bind(
	mainMod .. " + Z",
	hl.dsp.exec_cmd("pgrep -x qs && hyprctl dispatch global quickshell:showScreenOverLay"),
	{ description = "Show Screen Overlay" }
)

hl.bind(mainMod .. " + DELETE", hl.dsp.exec_cmd("pkill -x qs"))
