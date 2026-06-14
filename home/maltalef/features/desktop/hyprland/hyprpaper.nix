{ pkgs, config, ...}: {
	services.hyprpaper = {
		enable = true;
		settings = {
			# hyprpaper dibuja el splash de Hyprland ("try quickshell!") sobre el
			# wallpaper por su cuenta; misc:disable_splash_rendering de Hyprland no
			# lo cubre. Hay que apagarlo acá.
			splash = false;

			# hyprpaper (0.8.x) usa la categoría especial `wallpaper { }` y exige
			# `monitor` como PRIMER campo del bloque. Como home-manager genera las
			# keys en orden alfabético, "monitor" sale antes que "path" -> OK.
			# (No agregar fit_mode: alfabéticamente iría primero y rompería el
			# bloque; "cover" es el default igual.) monitor vacío => todos.
			# Ojo: el formato inline `wallpaper = monitor,path` ya no se procesa
			# desde el config en esta versión (solo vía IPC) -> daba "no target".
			wallpaper = {
				monitor = "";
				path = "${config.xdg.configHome}/hypr/wallpaper.jpg";
			};
		};
	};

	xdg.configFile."hypr/wallpaper.jpg".source = ./wallpaper.jpg;
}
