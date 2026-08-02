{pkgs, ...}: {
  programs.rofi = {
    enable = true;
    package = pkgs.rofi;
    theme = "solarized";
    extraConfig = {
      show-icons = true;
      icon-theme = "Papirus-Dark";
      drun-display-format = "{name}";
      display-drun = "Launch App";
    };
  };

  programs.git = {
    enable = true;
    settings = {
      user.name = "DFLTPLYR";
      user.email = "gonzales.johncris01@gmail.com";
    };
  };
  programs.direnv.enable = true;

  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.starship = {
    enable = true;
    settings = {};
  };

  programs.obs-studio = {
    enable = true;
    plugins = with pkgs.obs-studio-plugins; [
      droidcam-obs
    ];
  };
}
