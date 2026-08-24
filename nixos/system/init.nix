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
    ./nix.nix
    ./services.nix
    ./udev.nix
    ./user.nix
    ./lerd/lerd.nix
  ];

  nixpkgs.config.allowUnfree = true;
  system.stateVersion = "26.11";
}
