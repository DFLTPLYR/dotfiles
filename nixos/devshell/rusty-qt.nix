{pkgs}:
pkgs.mkShell {
  name = "rusty-qt-dev";

  nativeBuildInputs = with pkgs; [
    rustup
    pkg-config
    cmake
    gnumake
    wrapQtAppsHook
    qt6.qtbase
    qt6.qtdeclarative
    qt6.qttools
  ];

  buildInputs = with pkgs; [
    openssl
    wayland
    wayland-protocols
    libxkbcommon
    dbus
    gtk3
    libGL
    mesa
  ];

  shellHook = ''
    export QMAKE=$(which qmake6)
  '';
}
