{
  config,
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
  };
  xdg.configFile."nvim".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/.config/nvim";
}
