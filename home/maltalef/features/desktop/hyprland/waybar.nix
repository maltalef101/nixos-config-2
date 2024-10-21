{ pkgs, ... }: {
	programs.waybar = {
		enable = true;
		systemd.enable = true;

		settings = {
			layer = "top";
			position = "top";
			spacing = 4;

			modules-left = [
				"hyprland/workspaces"
				"hyprland/window"
			];
		};
	};
}
