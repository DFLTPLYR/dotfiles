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
      tree-sitter
      nixd
    ];
    extraPlugins = builtins.readFile ./plugins/ufo.lua;
    extraConfig = ''
      -- Options
      ${builtins.readFile ./options/keybinds.lua}
      ${builtins.readFile ./options/options.lua}

      -- Plugins
      ${builtins.readFile ./plugins/lsp.lua}
      ${builtins.readFile ./plugins/formatters.lua}
    '';
  };
}
