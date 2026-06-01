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

  networking.hostName = "nixosBtw"; # Define your hostname.

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Asia/Manila";
  services.getty.autologinUser = "dfltplyr";
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
    LC_ADDRESS = "fil_PH";
    LC_IDENTIFICATION = "fil_PH";
    LC_MEASUREMENT = "fil_PH";
    LC_MONETARY = "fil_PH";
    LC_NAME = "fil_PH";
    LC_NUMERIC = "fil_PH";
    LC_PAPER = "fil_PH";
    LC_TELEPHONE = "fil_PH";
    LC_TIME = "fil_PH";
  };
  environment.variables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
  };
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  users.users.dfltplyr = {
    isNormalUser = true;
    description = "dfltplyr";
    extraGroups = ["networkmanager" "wheel" "audio"];
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
    vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    neovim
    just
    rustup
    kitty

    wget
    git
    curl
    pciutils
    mpd
    mpdris2
    gcc
    fastfetch
    kdePackages.dolphin
    firefoxpwa
  ];

  # Enable sound with pipewire.
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
    wireplumber.enable = true; # Manages audio routing policies
  };
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
  ];
  nix.settings.experimental-features = ["nix-command" "flakes"];
  system.stateVersion = "26.05"; # Did you read the comment?
}
