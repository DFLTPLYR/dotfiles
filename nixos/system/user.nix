{
  config,
  pkgs,
  ...
}: {
  users.users.dfltplyr = {
    isNormalUser = true;
    description = "dfltplyr";
    extraGroups = ["networkmanager" "wheel" "audio" "mpd" "dialout"];
    packages = with pkgs; [
      tree
    ];
    shell = pkgs.zsh;
  };
}
