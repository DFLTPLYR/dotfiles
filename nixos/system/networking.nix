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
    "94.140.14.14"
    "94.140.15.15"
  ];
  networking.nameservers = [
    "94.140.14.14"
    "94.140.15.15"
  ];
}
