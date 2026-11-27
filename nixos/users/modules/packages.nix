{
  inputs,
  pkgs,
  ...
}: {
  home.packages = with pkgs; [
    # System / dotfiles
    adw-gtk3
    proton-vpn
    stow
    unzip
    wl-gammarelay-rs

    # Shell / CLI
    btop-rocm
    direnv
    fastfetch
    fd
    fetch
    fzf
    jq
    libnotify
    oh-my-zsh
    python314Packages.speedtest-cli
    ripgrep
    starship
    trash-cli

    # Terminal / TUI
    chafa
    helix
    inputs.herdr.packages.${pkgs.stdenv.hostPlatform.system}.default
    lazygit
    neovim
    tree-sitter
    ueberzugpp
    viu
    yazi

    # Media
    ani-cli
    cava
    easyeffects
    gpu-screen-recorder
    lowfi
    mpc
    mpv
    pavucontrol
    inputs.rmpc.packages.${pkgs.stdenv.hostPlatform.system}.default
    inputs.rmpc.packages.${pkgs.stdenv.hostPlatform.system}.rmpcd
    vlc

    # Development
    just
    llama-cpp-vulkan
    lmstudio
    nodejs
    opencode
    python314Packages.uv
    rustup
    wrangler

    # Desktop apps
    droidcam
    protonmail-desktop
    inputs.helium.packages.${pkgs.stdenv.hostPlatform.system}.default
    kitty
    localsend
    mindustry-wayland
    obsidian
    onlyoffice-desktopeditors
    prismlauncher
    protonplus
    telegram-desktop
    thunderbird
    (inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.default.override {
      wrapFirefox = browser: args:
        pkgs.wrapFirefox browser (args
          // {
            nativeMessagingHosts = [pkgs.firefoxpwa];
          });
    })

    # Screenshots / clipboard
    cliphist
    grim
    slurp
    wl-clipboard
  ];
}
