{pkgs}:
pkgs.mkShell {
  nativeBuildInputs = with pkgs; [
    pkg-config
  ];

  buildInputs = with pkgs; [
    wayland
    wayland-protocols
    libxkbcommon
    libdrm
  ];

  shellHook = ''
    echo "im in ¬‿¬"
  '';
}
