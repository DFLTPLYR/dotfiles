{
  config,
  pkgs,
  inputs,
  ...
}: {
  programs.vesktop = {
    enable = true;

    vencord.settings = {
      autoUpdate = true;
      autoUpdateNotification = true;
      notifyAboutUpdates = true;

      plugins = {
        ClearURLs.enabled = true;
        FixYoutubeEmbeds.enabled = true;
      };
    };
  };

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

  programs.starship = {
    enable = true;
    settings = {};
  };
}
