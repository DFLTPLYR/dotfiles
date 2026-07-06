{pkgs}:
pkgs.mkShell {
  name = "hello-world-dev";
  buildInputs = with pkgs; [
    rustup
    pkg-config
    qt6.qtbase
    qt6.qtdeclarative
  ];

  shellHook = ''
    export QMAKE=$(which qmake6)
    QTDECL=${pkgs.qt6.qtdeclarative}
    export CXXFLAGS="-I$QTDECL/include -I$QTDECL/include/QtQml"
  '';
}
