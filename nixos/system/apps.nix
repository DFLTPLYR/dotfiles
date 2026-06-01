{
  inputs,
  pkgs,
  ...
}: { 
  environment.systemPackages = with pkgs; [
    vim
    neovim
    just
    rustup
    kitty

    wget
    git
    curl
    pciutils
    mpd
    mpdris2-rs
    gcc
    fastfetch
    firefoxpwa
  ];


  programs.dconf.enable = true;
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
}
