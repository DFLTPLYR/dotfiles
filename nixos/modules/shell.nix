{
  config,
  pkgs,
  inputs,
  ...
}: {
  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.bash = {
    enable = true;
    shellAliases = {
      btw = "echo i use nixos, btw";
      c = "clear";
    };
    profileExtra = ''
      if [ -z "$WAYLAND_DISPLAY" ] && [ "$XDG_VTNR" = 1 ]; then
        exec start-hyprland
      fi
    '';
  };

  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;
    enableCompletion = true;

    oh-my-zsh = {
      enable = true;
      plugins = ["git" "direnv"];
      theme = "robbyrussell";
    };
    shellAliases = {
      vi = "nvim";
      vim = "nvim";
    };
    syntaxHighlighting.enable = true;
    initContent = ''
      export PATH="$HOME/.local/bin:$PATH"
      eval "$(fzf --zsh)"
      if [ -z "$WAYLAND_DISPLAY" ] && [ "$XDG_VTNR" = 1 ]; then
        exec start-hyprland
      fi
      for f in ~/.config/zsh/functions/*.zsh; do
        [ -r "$f" ] && source "$f"
      done
    '';
  };

  xdg.configFile."zsh".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/.config/zsh";

  programs.starship = {
    enable = true;
    settings = {};
  };
}
