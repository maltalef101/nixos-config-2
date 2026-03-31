{ libs, pkgs, inputs, ... }: {
	programs.hyprland = {
		enable = true;
		xwayland.enable = true;
		package = inputs.hyprland.packages.${pkgs.system}.hyprland;
	};

	security.pam.services.hyprlock = {};

	services.udev.extraRules = ''
		SUBSYSTEM="power_supply", ENV{POWER_SUPPLY_TYPE}=="Battery", ATTR{status}=="Discharging", ATTR{capacity}=="[0-19]|20", RUN+="${pkgs.notify-battery-status}"
	'';
}
