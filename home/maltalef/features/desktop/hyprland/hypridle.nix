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
			# listener. Bloqueo a los 5 min, apago pantalla a los 10 min.
			listener = [
				{
					timeout = 300;
					on-timeout = "loginctl lock-session";
				}
			];
		};
	};
}
