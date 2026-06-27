{
  inputs,
  pkgs,
  ...
}: {
  # AutoLogging.
  services.getty.autologinUser = "dfltplyr";
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  services.udev.extraRules = ''
    KERNEL=="hidraw*", ATTRS{idVendor}=="1d50", ATTRS{idProduct}=="615e", MODE="0666"

    # Disable USB wake from S5 to prevent devices from blocking shutdown
    SUBSYSTEM=="usb", ATTR{power/wakeup}="disabled"
  '';
}
