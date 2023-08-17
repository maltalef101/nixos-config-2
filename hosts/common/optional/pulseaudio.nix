{ pkgs, ... }: {
  security.rtkit.enable = true; # Pulseaudio uses rtkit for realtime scheduling
  sound.enable = true;
  hardware.pulseaudio = {
    enable = true;
	package = pkgs.pulseaudioFull;
  };
}
