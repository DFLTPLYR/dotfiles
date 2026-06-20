{pkgs, ...}: {
  imports = [
    ./modules/programs.nix
    ./modules/packages.nix
    ./modules/vesktop/vesktop.nix
    ./modules/shell/bash.nix
    ./modules/shell/zsh.nix
  ];

  home.username = "dfltplyr";
  home.homeDirectory = "/home/dfltplyr";
  home.stateVersion = "26.05";
  home.enableNixpkgsReleaseCheck = false; # Fixes the Home Manager version mismatch warning log
  home.sessionPath = [
    "$HOME/.local/bin"
  ];

  dconf.settings = {
    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
    };
  };

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
