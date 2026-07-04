{pkgs}:
let
  glibc-patched = pkgs.runCommand "glibc-patched" { } ''
    mkdir -p $out/include/gnu
    cp ${pkgs.glibc.dev}/include/gnu/stubs.h $out/include/gnu/stubs.h
    cp ${pkgs.glibc.dev}/include/gnu/stubs-64.h $out/include/gnu/stubs-64.h
    touch $out/include/gnu/stubs-32.h
  '';
in
pkgs.mkShell {
  name = "corne-rmk";
  nativeBuildInputs = with pkgs; [ clang ];

  LIBCLANG_PATH = "${pkgs.clang.cc.lib}/lib";
  BINDGEN_EXTRA_CLANG_ARGS = "-I${glibc-patched}/include";
}
