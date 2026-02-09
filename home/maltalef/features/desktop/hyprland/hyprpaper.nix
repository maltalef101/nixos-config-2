{ pkgs, inputs, ...}: {
	services.hyprpaper = {
		enable = true;
		settings = {
			wallpaper = {
				path = "${xdg.configHome}/hypr/wallpaper.jpg";
				fit_mode = "cover";
			};
		};
	};

	xdg.configFile."hypr/wallpaper.png".source = ./wallpaper.jpg;
}
