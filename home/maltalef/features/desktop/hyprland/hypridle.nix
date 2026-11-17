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
				# Desbloquear con la huella no es entrada de teclado ni de mouse:
				# sin esto, el escritorio queda con la pantalla apagada.
				on_unlock_cmd = "hyprctl dispatch dpms on";
			};

			# hypridle falla con "No rules configured" si no hay al menos un
			# listener. Bloqueo a los 5 min y apago la pantalla a los 15 min,
			# sin suspender (logind tiene IdleAction=ignore). hypridle cuenta
			# desde la última entrada, no desde el bloqueo: con el bloqueo a
			# mano, la pantalla se apaga 15 min después de la última tecla.
			#
			# El on-resume del dpms no es confiable: si un inhibit (Firefox
			# reproduciendo audio) vuelve a 0 estando idle, hypridle 0.1.8
			# destruye y recrea las notificaciones de inactividad
			# (CHypridle::onInhibit), y el «resumed» de las viejas no llega
			# nunca. Por eso la pantalla la prende Hyprland con cualquier
			# tecla o el mouse (misc:key_press_enables_dpms y
			# mouse_move_enables_dpms, en default.nix).
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
