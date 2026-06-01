{
  inputs,
  pkgs,
  ...
}: { 
  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-color-emoji
    liberation_ttf
    fira-code
    fira-code-symbols
    mplus-outline-fonts.githubRelease
    dina-font
    proggyfonts
    nerd-fonts.jetbrains-mono
  ];

  fonts.fontconfig.defaultFonts = {
    serif = ["Noto Serif" "Liberation Serif"];
    sansSerif = ["Noto Sans" "Liberation Sans"];
    monospace = ["Fira Code" "Noto Sans Mono"];
    emoji = ["Noto Color Emoji"];
  };
}
