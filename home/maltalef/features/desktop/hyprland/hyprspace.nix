{ pkgs, inputs, ... }: {
	# Overview de workspaces (hyprspace), accionado con swipe de 3 dedos hacia
	# arriba en el trackpad. Solo hosts portátiles: lo importa <host>.nix, no
	# el default.nix compartido.
	wayland.windowManager.hyprland = {
		# Vía keyword plugin= por consistencia con split-monitor-workspaces
		# (ver default.nix).
		extraConfig = "plugin = ${inputs.hyprspace.packages.${pkgs.system}.Hyprspace}/lib/libHyprspace.so";

		settings = {
			gesture = [
				"3, up, dispatcher, overview:toggle"
			];

			# waybar (layer top) queda a medio tapar por el overview;
			# esconderla mientras esté abierto
			plugin.overview.hideTopLayers = true;
		};
	};
}
