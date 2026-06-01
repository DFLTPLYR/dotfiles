{
  inputs,
  pkgs,
  ...
}: {
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
    pcmanfm-qt
    yazi
    pavucontrol
    btop-rocm
    obs-studio
    droidcam
    inputs.matugen.packages.${pkgs.stdenv.hostPlatform.system}.default
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
}
