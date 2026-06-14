{ libs, pkgs, inputs, ... }: {
	programs.hyprland = {
		enable = true;
		xwayland.enable = true;
		package = inputs.hyprland.packages.${pkgs.system}.hyprland;
	};

	# Sin esto, un display manager sin sesión recordada (p. ej. GDM) cae en su
	# fallback interno (gnome-session), que no está instalado -> falla al
	# arrancar la sesión. Al habilitar Hyprland, lo dejamos como sesión default.
	services.displayManager.defaultSession = "hyprland";

	security.pam.services.hyprlock = {};
}
