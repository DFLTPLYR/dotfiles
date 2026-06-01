{
  config,
  pkgs,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
    ./system/services.nix
    ./system/apps.nix
    ./system/fonts.nix
    ./system/audio.nix
    ./system/internationalization.nix
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


  # Enable networking
  networking.hostName = "nixosBtw"; # Define your hostname.
  networking.networkmanager.enable = true;


  environment.variables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
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

  hardware.graphics = {
    enable = true;
    enable32Bit = true; # Crucial for Steam / 32-bit games
    extraPackages = with pkgs; [
      rocmPackages.clr # Enables OpenCL support for the 5700XT (Blender, Davinci Resolve)
      libva-vdpau-driver
      libvdpau-va-gl
    ];
  };

  nixpkgs.config.allowUnfree = true;
  nix.settings.experimental-features = ["nix-command" "flakes"];
  system.stateVersion = "26.05"; # Did you read the comment?
}
