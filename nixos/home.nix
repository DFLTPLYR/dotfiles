{
  config,
  pkgs,
  inputs,
  ...
}: {
  imports = [ ./modules/general.nix ./modules/programs.nix ./modules/nvchad.nix ./modules/shell.nix];
  home.username = "dfltplyr";
  home.homeDirectory = "/home/dfltplyr";
  home.stateVersion = "26.05";
  home.enableNixpkgsReleaseCheck = false; # Fixes the Home Manager version mismatch warning log
  home.sessionPath = [
    "$HOME/.local/bin"
  ];

  # ui
  home.pointerCursor = {
    package = pkgs.bibata-cursors;
    name = "Bibata-Modern-Ice";
    size = 24;
  };

  gtk = {
    enable = true;
    cursorTheme = {
      package = pkgs.bibata-cursors;
      name = "Bibata-Modern-Ice";
      size = 24;
    };
    theme = {
      package = pkgs.adw-gtk3;
      name = "adw-gtk3-dark";
    };
    gtk3.extraConfig = {
      gtk-application-prefer-dark-theme = 1;
    };
    gtk4.extraConfig = {
      gtk-application-prefer-dark-theme = 1;
    };
  };

  qt = {
    enable = true;
    style.name = "breeze-dark";
    platformTheme.name = "qtct";
  };
}
