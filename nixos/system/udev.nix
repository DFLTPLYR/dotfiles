{
  inputs,
  pkgs,
  ...
}: {
  services.udev.extraRules = ''
    KERNEL=="hidraw*", ATTRS{idVendor}=="1d50", ATTRS{idProduct}=="615e", MODE="0666"
    # KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{serial}=="*vial:f64c2b3c*", MODE="0660", GROUP="users", TAG+="uaccess", TAG+="udev-acl"
    ACTION=="add", ATTRS{idVendor}=="6769", MODE="0666"
    ACTION=="add", ATTRS{idVendor}=="239a", MODE="0666"
  '';
}
