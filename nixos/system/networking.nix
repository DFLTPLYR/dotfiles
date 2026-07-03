{
  inputs,
  pkgs,
  ...
}: {
  # Enable networking
  networking.hostName = "nixosBtw"; # Define your hostname.
  networking.networkmanager.enable = true;
}
