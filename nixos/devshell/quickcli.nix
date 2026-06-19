{pkgs}:
pkgs.mkShell {
  nativeBuildInputs = with pkgs; [
    pkg-config
    wayland
    wayland-protocols
    libxkbcommon
    libdrm
    openssl
  ];

  shellHook = ''
    echo "im in ¬‿¬"
  '';
}
