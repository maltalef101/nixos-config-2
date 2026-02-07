{ inputs, outputs, lib, ... }: {
  imports = [
    ./global.nix
    #./features/desktop/leftwm
    ./features/desktop/hyprland
    ./features/desktop/common/optional/piper.nix
    ./features/desktop/common/optional/network.nix
    ./features/emacs
    ./features/games
	./features/tex
  ];

  wayland.windowManager.hyprland = {
	  settings = {
			device = [
				{ name = "2.4g-mouse"; sensitivity = "-0.1"; accel_profile = "flat"; }
				{ name = "genius-wireless-device-1"; accel_profile = "flat"; sensitivity = -0.36; }
			];
	  };
  };
}
