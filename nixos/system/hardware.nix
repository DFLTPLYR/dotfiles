{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}: {
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  boot.initrd.availableKernelModules = ["xhci_pci" "ahci" "nvme" "usbhid" "usb_storage" "sd_mod"];
  boot.initrd.kernelModules = [];
  boot.kernelModules = ["kvm-intel"];
  boot.extraModulePackages = [];

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/6f0f0782-f947-45e0-ae90-71c28dfa232f";
    fsType = "btrfs";
  };

  fileSystems."/home" = {
    device = "/dev/disk/by-uuid/6f0f0782-f947-45e0-ae90-71c28dfa232f";
    fsType = "btrfs";
    options = ["subvol=home"];
  };

  fileSystems."/nix" = {
    device = "/dev/disk/by-uuid/6f0f0782-f947-45e0-ae90-71c28dfa232f";
    fsType = "btrfs";
    options = ["subvol=nix"];
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/6BA9-CEA3";
    fsType = "vfat";
    options = ["fmask=0077" "dmask=0077"];
  };

  fileSystems."/storageBtw" = {
    device = "/dev/disk/by-uuid/a7496664-5f01-4c7a-8372-366e0194f234";
    fsType = "ext4";
    options = ["defaults" "nofail"];
  };

  swapDevices = [
    {device = "/dev/disk/by-uuid/0c21e6c4-1ac5-47dd-aa8d-4b1f1e4ba376";}
  ];

  hardware.graphics = {
    enable = true;
    enable32Bit = true; # Crucial for Steam / 32-bit games
    extraPackages = with pkgs; [
      rocmPackages.clr
      libva-vdpau-driver
      libvdpau-va-gl
    ];
  };
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
