{
  config,
  pkgs,
  ...
}: {
  imports = [
    ./apps.nix
    ./audio.nix
    ./boot.nix
    ./env.nix
    ./fonts.nix
    ./hardware.nix
    ./kernel.nix
    ./internationalization.nix
    ./networking.nix
    ./services.nix
    ./udev.nix
    ./user.nix
    ./lerd/lerd.nix
  ];

  nixpkgs.config.allowUnfree = true;
  nix.settings.experimental-features = ["nix-command" "flakes"];
  system.stateVersion = "26.11";
}
