{
  config,
  pkgs,
  inputs,
  ...
}: {
  imports = [./modules/nvchad.nix ./modules/shell.nix];
  home.username = "dfltplyr";
  home.homeDirectory = "/home/dfltplyr";
  home.stateVersion = "26.05";
  home.enableNixpkgsReleaseCheck = false; # Fixes the Home Manager version mismatch warning log
  home.sessionPath = [
    "$HOME/.local/bin"
  ];
  home.pointerCursor = {
    package = pkgs.bibata-cursors;
    name = "Bibata-Modern-Ice";
    size = 24;
  };

  home.packages = with pkgs; [
    # System / dotfiles
    stow
    wayland
    pkg-config

    # Shell / CLI
    starship
    oh-my-zsh
    ripgrep
    fd
    fzf
    lazygit
    direnv
    libnotify
    mpc

    # Development
    nodejs
    opencode

    # Apps
    discord
    telegram-desktop
    thunderbird
    nemo
    yazi
    pavucontrol
    btop-rocm
    inputs.matugen.packages.${system}.default
    inputs.rmpc.packages.${pkgs.stdenv.hostPlatform.system}.default
    inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.default
    (pkgs.quickshell.overrideAttrs (old: {
      cmakeFlags =
        (old.cmakeFlags or [])
        ++ [
          "-DHYPRLAND=OFF"
          "-DHYPRLAND_GLOBAL_SHORTCUTS=OFF"
          "-DHYPRLAND_FOCUS_GRAB=OFF"
          "-DI3=OFF"
          "-DI3_IPC=OFF"
        ];
    }))

    # Screenshots / clipboard
    grim
    slurp
    cliphist
    wl-clipboard
  ];

  gtk = {
    enable = true;
    cursorTheme = {
      package = pkgs.bibata-cursors;
      name = "Bibata-Modern-Ice";
      size = 24;
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
    platformTheme = "qtct";
  };

  programs.rofi = {
    enable = true;
    package = pkgs.rofi;
    theme = "solarized";
  };

  programs.git = {
    enable = true;
    settings = {
      user.name = "DFLTPLYR";
      user.email = "gonzales.johncris01@gmail.com";
    };
  };
}
