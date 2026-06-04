{pkgs}:
pkgs.mkShell {
  nativeBuildInputs = with pkgs; [
    pkg-config
    wayland
    wayland-protocols
    libxkbcommon
    libdrm
  ];

  shellHook = ''
    echo "im in ¬‿¬"
  '';
}
