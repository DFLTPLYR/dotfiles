local home = os.getenv("HOME")

terminal = "kitty"
filemanager = "kitty -e yazi"
menu = "pkill rofi || rofi -show drun -p 'Launch App'"
clipboard = [[pkill rofi || cliphist list | rofi -dmenu | cliphist decode | wl-copy]]
browser = "zen"
editor = "nvim"

local function desktop_env(qs_args, riced_cmd)
	return string.format(
		"if pgrep -f quickshell >/dev/null; then qs -c reshell ipc call config %s; else %s; fi",
		qs_args,
		riced_cmd
	)
end

settings = desktop_env("toggleSettings", "riced settings")
clip = desktop_env("clip", "riced ...")

selectshot =
	[[mkdir -p ~/Pictures/Screenshots && grim -g "$(slurp)" - | tee ~/Pictures/Screenshots/$(date +%Y-%m-%d_%H-%M-%S).png | wl-copy]]
screenshot =
	[[mkdir -p ~/Pictures/Screenshots && grim -g "$(slurp -o)" - | tee ~/Pictures/Screenshots/$(date +%Y-%m-%d_%H-%M-%S).png | wl-copy]]
