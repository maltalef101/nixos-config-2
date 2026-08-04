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

	# Sin pam_fprintd: la conversación PAM de hyprlock es serial, así que el
	# módulo de huella bloquea pidiendo el dedo antes de aceptar la contraseña.
	# La huella la maneja hyprlock nativamente (auth:fingerprint), en paralelo.
	security.pam.services.hyprlock.fprintAuth = false;
}
