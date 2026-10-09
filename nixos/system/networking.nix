{
  inputs,
  pkgs,
  ...
}: {
  # Enable networking
  networking.hostName = "nixosBtw"; # Define your hostname.
  networking.networkmanager.enable = true;
  networking.networkmanager.dns = "systemd-resolved";
  networking.networkmanager.insertNameservers = [
    "8.8.8.8"
    "8.8.4.4"
  ];
  networking.nameservers = [
    "8.8.8.8"
    "8.8.4.4"
  ];
}
