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
    helix
    unzip
    tree-sitter
    viu
    chafa
    ueberzugpp

    # Shell / CLI
    wl-gammarelay-rs
    ani-cli
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
    python314Packages.speedtest-cli
    btop-rocm
    trash-cli
    inputs.matugen.packages.${pkgs.stdenv.hostPlatform.system}.default
    inputs.rmpc.packages.${pkgs.stdenv.hostPlatform.system}.default
    inputs.herdr.packages.${pkgs.stdenv.hostPlatform.system}.default
    (pkgs.firefoxpwa-unwrapped.override {firefoxRuntime = pkgs.firefox-unwrapped;})
    fetch

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
    droidcam
    adw-gtk3
    inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.default
    kitty
    obsidian
    mpdris2-rs
    onlyoffice-desktopeditors
    vlc
    localsend
    aseprite
    vial

    # Screenshots / clipboard
    grim
    slurp
    cliphist
    wl-clipboard
  ];
}
