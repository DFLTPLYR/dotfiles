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
  home.packages = with pkgs; [
    stow
    discord
    nodejs
    telegram-desktop
    thunderbird
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
    starship
    ripgrep
    fd
    oh-my-zsh
    lazygit
    direnv
    nixfmt
    fzf
    nemo
    yazi
    pavucontrol
    btop-rocm
    libnotify
    zed-editor
    pkg-config
    wayland
    opencode
    mpc
  ];

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
