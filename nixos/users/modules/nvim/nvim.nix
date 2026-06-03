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
    extraPlugins = builtins.readFile ./ufo.lua;
    extraConfig = ''
      ${builtins.readFile ./lsp.lua}
      ${builtins.readFile ./keybinds.lua}
      ${builtins.readFile ./formatters.lua}
      ${builtins.readFile ./options.lua}
    '';
  };
  home.packages = with pkgs; [
    qt6.qtdeclarative
  ];
}
