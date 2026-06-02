{
  inputs,
  pkgs,
  ...
}: {
  nixpkgs.overlays = [inputs.millennium.overlays.default];

  environment.systemPackages = with pkgs; [
    vim
    wget
    git
    curl
    pciutils
    mpd
    mpdris2-rs
    gcc
  ];

  programs.dconf.enable = true;
  programs.zsh.enable = true;

  programs.firefox = {
    enable = true;
    package = pkgs.firefox;
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
