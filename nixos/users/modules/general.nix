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
    cava
    starship
    oh-my-zsh
    ripgrep
    fd
    fzf
    fastfetch
    lazygit
    direnv
    libnotify
    mpc
    yazi
    speedtest-rs
    btop-rocm
    trash-cli
    inputs.matugen.packages.${pkgs.stdenv.hostPlatform.system}.default
    inputs.rmpc.packages.${pkgs.stdenv.hostPlatform.system}.default

    # Development
    nodejs
    opencode
    rustup
    just

    # Apps
    discord
    telegram-desktop
    thunderbird
    pavucontrol
    obs-studio
    droidcam
    adw-gtk3
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
    kitty

    # Screenshots / clipboard
    grim
    slurp
    cliphist
    wl-clipboard
  ];
}
