{ inputs, outputs, lib, ... }: {
  imports = [
    ./global.nix
    ./features/desktop/hyprland
    ./features/desktop/hyprland/pantallas.nix
    ./features/desktop/common/optional/batsignal.nix
    ./features/desktop/common/optional/piper.nix
    ./features/desktop/common/optional/network.nix
    # el navegador por omisión (Firefox sigue, detrás)
    ./features/desktop/common/optional/qutebrowser
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

			# la Wacom (Intuos CTL-6100WL) entera sobre el monitor de arriba
			input.tablet.output = "DP-1";

			# los externos los acomoda hypr-pantallas (ver pantallas.monitores abajo);
			# esta regla vale solo hasta que el vigía los ve
			monitor = [
				"eDP-1, 1920x1080, 0x0, 1"
				", preferred, auto, 1"
			];
	  };
  };

  # lo de cada monitor hasta que se elija otra cosa en el menú (F7 o $mod+o)
  pantallas.monitores = [
	# por descripción primero (gana sobre el puerto, como desc: en Hyprland)
	# el ASR solo llega a 120 Hz
	{ desc = "ASR CL25FFA"; lugar = "derecha"; modo = "1920x1080@120"; }
	# el KTC 27GR951 (por el dock o por HDMI); ofrece 200 Hz, va a 180
	{ desc = "SAC LED MONITOR"; lugar = "arriba"; modo = "1920x1080@180"; }
	# espeja el DP-1 si está; si no, centrado encima del eDP
	{ puerto = "HDMI-A-1"; lugar = "arriba"; espejo = "DP-1"; modo = "1920x1080@100"; }
	{ puerto = "DP-2"; lugar = "derecha"; }
  ];
}
