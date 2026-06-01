{
  inputs,
  pkgs,
  ...
}: {
  # Enable sound.
  services.mpd = {
    enable = true;
    user = "dfltplyr";
    settings = {
      bind_to_address = "127.0.0.1";
      music_directory = "/storageBtw/Music";
      audio_output = [
        {
          type = "pipewire";
          name = "PipeWire Output";
          mixer_type = "software";
        }
        {
          type = "fifo";
          name = "Visualizer";
          path = "/tmp/mpd.fifo";
        }
      ];
    };
  };

  systemd.services.mpd.environment = {
    PIPEWIRE_RUNTIME_DIR = "/run/user/1000";
    PULSE_SERVER = "unix:/run/user/1000/pulse/native";
  };

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
    wireplumber.enable = true; # Manages audio routing policies
  };
}
