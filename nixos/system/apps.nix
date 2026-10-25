{
  inputs,
  pkgs,
  ...
}: {
  nixpkgs.overlays = [
    inputs.millennium.overlays.default
    (final: prev: {
      firefoxpwa-unwrapped = prev.firefoxpwa-unwrapped.overrideAttrs (old: rec {
        version = "2.20.1";
        src = prev.fetchFromGitHub {
          owner = "filips123";
          repo = "PWAsForFirefox";
          tag = "v${version}";
          hash = "sha256-kOtdGRW2DN0qQLrtvbsywBdGlM/1cboQGu2NM7cO8E8=";
        };
      });
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
    bun
    papirus-icon-theme
    firefoxpwa
  ];

  nix.nixPath = ["nixpkgs=${inputs.nixpkgs}"];
  programs.nix-ld.enable = true;
  programs.dconf.enable = true;
  programs.zsh.enable = true;

  programs.firefox = {
    enable = true;
    package = pkgs.firefox;
    nativeMessagingHosts.packages = [pkgs.firefoxpwa];
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
