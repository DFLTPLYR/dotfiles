local home = os.getenv("HOME")

terminal = "kitty"
filemanager = "kitty -e yazi"
menu = "pkill rofi || rofi -show drun -p 'Launch App'"
clipboard = [[pkill rofi || cliphist list | rofi -dmenu | cliphist decode | wl-copy]]
browser = "zen"
editor = "nvim"

qs_config = "qs -c reshell ipc call config"
mode = qs_config .. " cycleState"
selectshot =
	[[mkdir -p ~/Pictures/Screenshots && grim -g "$(slurp)" - | tee ~/Pictures/Screenshots/$(date +%Y-%m-%d_%H-%M-%S).png | wl-copy]]
screenshot =
	[[mkdir -p ~/Pictures/Screenshots && grim -g "$(slurp -o)" - | tee ~/Pictures/Screenshots/$(date +%Y-%m-%d_%H-%M-%S).png | wl-copy]]
