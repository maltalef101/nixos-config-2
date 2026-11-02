{ pkgs, ... }: {
	services.hypridle = {
		enable = true;
		settings = {
			general = {
				# Wrapper: guard por usuario + LockedHint de logind (hyprlock
				# no setea el hint, hyprwm/hyprlock#907).
				lock_cmd = "hyprlock-lock";
				before_sleep_cmd = "loginctl lock-session";
				after_sleep_cmd = "hyprctl dispatch dpms on";
			};

			# hypridle falla con "No rules configured" si no hay al menos un
			# listener. Bloqueo a los 5 min y apago la pantalla a los 15 min,
			# sin suspender (logind tiene IdleAction=ignore). hypridle cuenta
			# desde la última entrada, no desde el bloqueo: con el bloqueo a
			# mano, la pantalla se apaga 15 min después de la última tecla.
			listener = [
				{
					timeout = 300;
					on-timeout = "loginctl lock-session";
				}
				{
					timeout = 900;  # 15 min de inactividad = 10 min después del bloqueo automático (a los 300 s)
					on-timeout = "hyprctl dispatch dpms off";
					on-resume = "hyprctl dispatch dpms on";
				}
			];
		};
	};
}
