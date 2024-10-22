{ pkgs, ... }: {
	programs.waybar = {
		enable = true;
		systemd.enable = true;

		settings = {
			mainbar = {
				layer = "top";
				position = "top";
				spacing = 4;

				modules-left = [
					"hyprland/workspaces"
					"hyprland/window"
				];

				"hyprland/workspaces" = {
					active-only = false;
					all-outputs = true;
				};
			};
		};
	};
}
