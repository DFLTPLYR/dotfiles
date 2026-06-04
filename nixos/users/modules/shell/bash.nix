{
  config,
  pkgs,
  inputs,
  ...
}: {
  programs.bash = {
    enable = true;
    shellAliases = {
      btw = "echo i use nixos, btw";
      c = "clear";
    };
    profileExtra = ''
      if [ -z "$WAYLAND_DISPLAY" ] && [ "$XDG_VTNR" = 1 ]; then
        exec start-hyprland
      fi
    '';
  };
}
