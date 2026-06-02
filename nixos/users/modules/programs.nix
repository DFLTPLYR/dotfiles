{
  inputs,
  pkgs,
  ...
}: {
  programs.rofi = {
    enable = true;
    package = pkgs.rofi;
    theme = "solarized";
  };

  programs.git = {
    enable = true;
    settings = {
      user.name = "DFLTPLYR";
      user.email = "gonzales.johncris01@gmail.com";
    };
  };
}
