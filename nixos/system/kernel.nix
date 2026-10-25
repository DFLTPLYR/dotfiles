{
  config,
  pkgs,
  ...
}: {
  # Use latest kernel. Zen Btw
  boot.kernelPackages = pkgs.linuxPackages_zen;
  boot.kernelModules = ["v4l2loopback"];
  boot.kernelParams = ["acpi=force"];
  boot.extraModulePackages = [
    (config.boot.kernelPackages.v4l2loopback.overrideAttrs (old: {
      postInstall =
        (old.postInstall or "")
        + ''
          find $out/lib/modules -mindepth 2 -maxdepth 2 -name 'modules.*' -delete
        '';
    }))
  ];
  boot.extraModprobeConfig = ''
    options v4l2loopback exclusive_caps=1 video_nr=7 card_label="DroidCam"
  '';
  system.boot.loader.kernelFile = "bzImage";
}
