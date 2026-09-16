{ pkgs, ... }: {
	# genera ~/.config/mimeapps.list declarativamente; sin este enable los
	# defaultApplications que declaran los módulos de apps son config muerta
	xdg.mimeApps.enable = true;

	# ya existía un mimeapps.list mutable (signal y claude-code se registraron
	# solos en runtime); sin force el switch aborta. Al quedar como symlink
	# read-only las apps ya no pueden auto-registrarse: los handlers nuevos
	# se declaran acá (los que ya existían están migrados abajo)
	xdg.configFile."mimeapps.list".force = true;

	# terminal para lanzar .desktop con Terminal=true (p. ej. nvim.desktop):
	# glib y xdg-open delegan en xdg-terminal-exec, que lee esta lista; la
	# config de usuario gana sobre /etc/xdg
	home.packages = [ pkgs.xdg-terminal-exec ];
	xdg.configFile."xdg-terminals.list".text = "foot.desktop\n";

	# defaults de apps sin módulo propio; zathura, firefox y superfile
	# reclaman sus tipos en sus propios módulos
	xdg.mimeApps.defaultApplications = {
		"image/png" = [ "nsxiv.desktop" ];
		"image/jpeg" = [ "nsxiv.desktop" ];
		"image/gif" = [ "nsxiv.desktop" ];
		"image/webp" = [ "nsxiv.desktop" ];
		"image/bmp" = [ "nsxiv.desktop" ];
		"image/tiff" = [ "nsxiv.desktop" ];
		"image/svg+xml" = [ "nsxiv.desktop" ];

		"video/mp4" = [ "mpv.desktop" ];
		"video/webm" = [ "mpv.desktop" ];
		"video/x-matroska" = [ "mpv.desktop" ];
		"video/quicktime" = [ "mpv.desktop" ];
		"video/x-msvideo" = [ "mpv.desktop" ];
		"video/mpeg" = [ "mpv.desktop" ];

		"audio/mpeg" = [ "mpv.desktop" ];
		"audio/flac" = [ "mpv.desktop" ];
		"audio/ogg" = [ "mpv.desktop" ];
		"audio/x-wav" = [ "mpv.desktop" ];
		"audio/mp4" = [ "mpv.desktop" ];
		"audio/opus" = [ "mpv.desktop" ];

		# nvim.desktop trae Terminal=true -> abre en foot vía xdg-terminal-exec
		"text/plain" = [ "nvim.desktop" ];
		"text/markdown" = [ "nvim.desktop" ];

		"x-scheme-handler/mailto" = [ "thunderbird.desktop" ];

		# migrados del mimeapps.list mutable previo a declararlo
		"x-scheme-handler/signalcaptcha" = [ "signal.desktop" ];
		"x-scheme-handler/claude-cli" = [ "claude-code-url-handler.desktop" ];
	};
}
