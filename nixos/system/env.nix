{
  config,
  pkgs,
  ...
}: {
  environment.variables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
    QT_QPA_PLATFORMTHEME = "qt6ct";
    NIXOS_OZONE_WL = "1";
    BROWSER = "zen";
    TERMINAL = "kitty";
  };
}
