{
  inputs,
  pkgs,
  ...
}: {
  programs.vesktop = {
    enable = true;

    vencord.settings = {
      autoUpdate = true;
      autoUpdateNotification = true;
      notifyAboutUpdates = true;
      useQuickCss = true;
      enabledThemes = "~/.config/vesktop/themes/vesktop.css";
      plugins = {
        ClearURLs.enabled = true;
        FixYoutubeEmbeds.enabled = true;
      };
    };
  };
}
