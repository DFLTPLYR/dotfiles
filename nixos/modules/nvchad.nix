{
  inputs,
  pkgs,
  ...
}: {
  imports = [inputs.nix4nvchad.homeManagerModules.default];
  programs.nvchad = {
    enable = true;
    extraPackages = with pkgs; [
      ripgrep
      lua-language-server
      stylua
      bash-language-server
      alejandra
      typescript-language-server
      pyright
      rust-analyzer
      vue-language-server
    ];
    extraConfig = builtins.readFile ./nvchad.lua;
  };
  home.packages = with pkgs; [
    qt6.qtdeclarative
  ];
}
