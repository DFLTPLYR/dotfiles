{
  inputs,
  pkgs,
  ...
}: {
  nixpkgs.overlays = [
    inputs.millennium.overlays.default
    (final: prev: {
      vesktop = prev.vesktop.override {
        pnpm_10_29_2 = final.pnpm_10;
      };
    })
  ];

  environment.systemPackages = with pkgs; [
    vim
    wget
    git
    curl
    pciutils
    mpd
    gcc
    zip
    bc
  ];
  nix.nixPath = ["nixpkgs=${inputs.nixpkgs}"];
  programs.nix-ld.enable = true;
  programs.dconf.enable = true;
  programs.zsh.enable = true;

  programs.firefox = {
    enable = true;
    package = pkgs.firefox;
    nativeMessagingHosts.packages = [pkgs.firefoxpwa-unwrapped];
  };

  programs.steam = {
    enable = true;
    package = pkgs.millennium-steam;
    remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
    dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
  };

  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

  xdg.portal = {
    enable = true;
    extraPortals = [pkgs.xdg-desktop-portal-gtk];
  };

  programs.gamemode.enable = true;
}
