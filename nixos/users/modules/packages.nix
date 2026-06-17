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
    qt6.qtdeclarative
    ((pkgs.quickshell.override {stdenv = pkgs.clangStdenv;}).overrideAttrs (old: {
      cmakeFlags =
        (old.cmakeFlags or [])
        ++ [
          "-DX11=OFF"
          "-DHYPRLAND=OFF"
          "-DHYPRLAND_GLOBAL_SHORTCUTS=OFF"
          "-DHYPRLAND_FOCUS_GRAB=OFF"
          "-DI3=OFF"
          "-DI3_IPC=OFF"
        ];
    }))
    neovim
    unzip
    tree-sitter

    # Shell / CLI
    cava
    starship
    oh-my-zsh
    ripgrep
    jq
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
    (pkgs.firefoxpwa-unwrapped.override {firefoxRuntime = pkgs.firefox-unwrapped;})

    # Development
    nodejs
    opencode
    rustup
    just
    lmstudio

    # Apps
    telegram-desktop
    thunderbird
    pavucontrol
    obs-studio
    droidcam
    adw-gtk3
    inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.default
    kitty
    obsidian
    mpdris2-rs

    # Screenshots / clipboard
    grim
    slurp
    cliphist
    wl-clipboard
  ];
}
