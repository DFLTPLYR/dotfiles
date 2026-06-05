{config, ...}: {
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
      speedtest = "speedtest-rs";
    };
    syntaxHighlighting.enable = true;
    initContent = ''
      export PATH="$HOME/.cargo/bin:$HOME/.local/bin:$PATH"
      eval "$(fzf --zsh)"
      if [ -z "$WAYLAND_DISPLAY" ] && [ "$XDG_VTNR" = 1 ]; then
        exec start-hyprland
      fi
      for f in ~/.config/zsh/functions/*.zsh; do
        [ -r "$f" ] && source "$f"
      done
      eval "$(direnv hook zsh)"
      fastfetch
    '';
  };
  xdg.configFile."zsh".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/.config/zsh";
}
