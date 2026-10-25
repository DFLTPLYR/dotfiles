{ lib, pkgs, ... }:

let
  graphify = pkgs.writeShellApplication {
    name = "graphify";

    runtimeInputs = [ pkgs.uv pkgs.python313 ];

    text = ''
      # Keep native dependencies local to Graphify and its subprocesses.
      export LD_LIBRARY_PATH="${lib.makeLibraryPath [ pkgs.stdenv.cc.cc.lib ]}''${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
      export UV_PYTHON_DOWNLOADS=never

      # The distribution is named graphifyy; its executable is graphify.
      exec uv tool run \
        --python ${pkgs.python313}/bin/python3 \
        --from graphifyy \
        graphify "$@"
    '';
  };
in
{
  environment.systemPackages = [ graphify ];
}
