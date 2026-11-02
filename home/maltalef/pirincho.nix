{ inputs, outputs, lib, ... }: {
  imports = [
    ./global.nix
    ./features/desktop/hyprland
    ./features/desktop/hyprland/laptop-scale.nix
    ./features/desktop/common/optional/batsignal.nix
    ./features/desktop/common/optional/piper.nix
    ./features/desktop/common/optional/network.nix
    ./features/cli/optional/claude-swap.nix
    ./features/emacs
    ./features/games
	./features/tex
  ];

  # El tema con la paleta gruvbox-verde (gruvbox-dark-hard, acento #689d6a), las fuentes de antes y el fondo de
  # siempre; mw sigue en gruvbox sin el tema
  tema = {
    enable = true;
    paleta = "gruvbox-verde";
    fondo.imagen = ./features/desktop/hyprland/wallpaper.jpg;
  };

  wayland.windowManager.hyprland = {
	  settings = {
			device = [
				{ name = "2.4g-mouse"; sensitivity = "-0.1"; accel_profile = "flat"; }
				{ name = "genius-wireless-device-1"; accel_profile = "flat"; sensitivity = -0.36; }
				{ name = "tpps/2-elan-trackpoint"; accel_profile = "flat"; }
			];

			monitor = [
				"eDP-1, 1920x1080, 0x0, 1"
				"HDMI-A-1, 1920x1080@100, 0x-1080, 1"
				"DP-1, 1920x1080@180, 0x-1080, 1"
				# x=1536: ancho lógico del eDP a 1.25 (hypr-laptop-scale)
				"DP-2, 1920x1080, 1536x0, 1"
				# por descripción (gana sobre el nombre del puerto); va a la
				# derecha y solo llega a 120 Hz
				"desc:ASR CL25FFA, 1920x1080@120, 1536x0, 1"
			];
	  };
  };
}
