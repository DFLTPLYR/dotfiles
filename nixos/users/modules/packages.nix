{
  inputs,
  pkgs,
  ...
}: {
  home.packages = with pkgs; [
    # System / dotfiles
    stow
    qt6.qtbase
    qt6.qtdeclarative
    qt6.qtwayland
    neovim
    helix
    unzip
    tree-sitter
    viu
    chafa
    ueberzugpp
    proton-vpn

    # Shell / CLI
    wl-gammarelay-rs
    gpu-screen-recorder
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
    inputs.rmpc.packages.${pkgs.stdenv.hostPlatform.system}.default
    inputs.rmpc.packages.${pkgs.stdenv.hostPlatform.system}.rmpcd
    inputs.herdr.packages.${pkgs.stdenv.hostPlatform.system}.default
    (pkgs.firefoxpwa-unwrapped.override {firefoxRuntime = pkgs.firefox-unwrapped;})
    fetch
    lowfi

    # Development
    nodejs
    opencode
    rustup
    just
    lmstudio
    qtcreator
    wrangler

    # Apps
    telegram-desktop
    thunderbird
    pavucontrol
    droidcam
    adw-gtk3
    inputs.helium.packages.${pkgs.stdenv.hostPlatform.system}.default
    # Zen re-uploaded the 1.23.3b tarball upstream, so the flake's pinned hash
    # is stale. Remove this override once zen-browser-flake updates sources.json.
    (let
      unwrapped = inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.zen-browser-unwrapped.override {
        hash = "sha256-uyBF0+IWVNQP6EElAJLurf0sH8gx7vtQkiJ3PIvcoUk=";
      };
    in
      pkgs.wrapFirefox unwrapped {
        pname = "zen-browser";
        version = unwrapped.version;
      })
    kitty
    obsidian
    mpdris2-rs
    onlyoffice-desktopeditors
    vlc
    localsend
    protonplus
    prismlauncher

    # Screenshots / clipboard
    grim
    slurp
    cliphist
    wl-clipboard
  ];
}
