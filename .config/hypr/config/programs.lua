local home = os.getenv("HOME")

terminal = "kitty"
filemanager = "kitty -e yazi"
menu = "rofi -show drun -p 'Launch App'"
browser = "zen"
editor = "nvim"
mode = "quickcli launch cycleState"
selectshot = [[mkdir -p ~/Pictures/Screenshots && grim -g "$(slurp)" - | tee ~/Pictures/Screenshots/$(date +%Y-%m-%d_%H-%M-%S).png | wl-copy]]
screenshot = [[mkdir -p ~/Pictures/Screenshots && grim -g "$(slurp -o)" - | tee ~/Pictures/Screenshots/$(date +%Y-%m-%d_%H-%M-%S).png | wl-copy]]
