{ lib, pkgs, inputs, ... }:
let
	# Los display managers ejecutan el Exec de la sesión sin pasar por ningún
	# shell, así que las hm-session-vars (GNUPGHOME, PASSWORD_STORE_DIR, ...)
	# no llegan a la sesión gráfica. Esta sesión pasa por un login shell
	# (pkgs/scripts/start-hyprland-login) que las carga vía .zprofile.
	hyprland-login-session = pkgs.writeTextFile {
		name = "hyprland-login-session";
		destination = "/share/wayland-sessions/hyprland-login.desktop";
		text = ''
			[Desktop Entry]
			Name=Hyprland (login shell)
			Comment=Hyprland con las hm-session-vars del usuario cargadas
			Exec=${lib.getExe pkgs.start-hyprland-login}
			Type=Application
		'';
		derivationArgs.passthru.providedSessions = [ "hyprland-login" ];
	};
in {
	programs.hyprland = {
		enable = true;
		xwayland.enable = true;
		package = inputs.hyprland.packages.${pkgs.system}.hyprland;
	};

	services.displayManager.sessionPackages = [ hyprland-login-session ];

	# Sin esto, un display manager sin sesión recordada (p. ej. GDM) cae en su
	# fallback interno (gnome-session), que no está instalado -> falla al
	# arrancar la sesión. Al habilitar Hyprland, lo dejamos como sesión default.
	services.displayManager.defaultSession = "hyprland-login";

	# Sin pam_fprintd: la conversación PAM de hyprlock es serial, así que el
	# módulo de huella bloquea pidiendo el dedo antes de aceptar la contraseña.
	# La huella la maneja hyprlock nativamente (auth:fingerprint), en paralelo.
	security.pam.services.hyprlock.fprintAuth = false;
}
