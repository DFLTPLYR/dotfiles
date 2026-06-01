{
  config,
  pkgs,
  ...
}: {
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Use latest kernel.
  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.kernelModules = ["v4l2loopback"];
  boot.extraModulePackages = with config.boot.kernelPackages; [v4l2loopback];
  boot.extraModprobeConfig = ''
    options v4l2loopback exclusive_caps=1 video_nr=7 card_label="DroidCam"
  '';

  networking.hostName = "nixosBtw"; # Define your hostname.

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Asia/Manila";
  services.getty.autologinUser = "dfltplyr";
  programs.dconf.enable = true;
  programs.zsh.enable = true;
  programs.firefox = {
    enable = true;
    package = pkgs.firefox;
    nativeMessagingHosts.packages = [pkgs.firefoxpwa];
  };
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
    dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
  };
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };
  programs.gamemode.enable = true;

  # Select internationalisation properties.
  i18n.defaultLocale = "en_PH.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_PH.UTF-8";
    LC_IDENTIFICATION = "en_PH.UTF-8";
    LC_MEASUREMENT = "en_PH.UTF-8";
    LC_MONETARY = "en_PH.UTF-8";
    LC_NAME = "en_PH.UTF-8";
    LC_NUMERIC = "en_PH.UTF-8";
    LC_PAPER = "en_PH.UTF-8";
    LC_TELEPHONE = "en_PH.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  environment.variables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
  };

  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };
  # Enable sound.
  services.mpd = {
    enable = true;
    musicDirectory = "/storageBtw/Music";
    network.listenAddress = "127.0.0.1";
    settings = {
      audio_output = [
        {
          type = "fifo";
          name = "Visualizer";
          path = "/tmp/mpd.fifo";
        }
      ];
    };
  };

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
    wireplumber.enable = true; # Manages audio routing policies
  };

  users.users.dfltplyr = {
    isNormalUser = true;
    description = "dfltplyr";
    extraGroups = ["networkmanager" "wheel" "audio" "mpd"];
    packages = with pkgs; [
      tree
    ];
    shell = pkgs.zsh;
  };

  nixpkgs.config.allowUnfree = true;

  hardware.graphics = {
    enable = true;
    enable32Bit = true; # Crucial for Steam / 32-bit games
    extraPackages = with pkgs; [
      rocmPackages.clr # Enables OpenCL support for the 5700XT (Blender, Davinci Resolve)
      libva-vdpau-driver
      libvdpau-va-gl
    ];
  };

  environment.systemPackages = with pkgs; [
    vim
    neovim
    just
    rustup
    kitty

    wget
    git
    curl
    pciutils
    mpd
    mpdris2-rs
    gcc
    fastfetch
    firefoxpwa
  ];

  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-color-emoji
    liberation_ttf
    fira-code
    fira-code-symbols
    mplus-outline-fonts.githubRelease
    dina-font
    proggyfonts
    nerd-fonts.jetbrains-mono
  ];

  fonts.fontconfig.defaultFonts = {
    serif = ["Noto Serif" "Liberation Serif"];
    sansSerif = ["Noto Sans" "Liberation Sans"];
    monospace = ["Fira Code" "Noto Sans Mono"];
    emoji = ["Noto Color Emoji"];
  };

  nix.settings.experimental-features = ["nix-command" "flakes"];
  system.stateVersion = "26.05"; # Did you read the comment?
}
