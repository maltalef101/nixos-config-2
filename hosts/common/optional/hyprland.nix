{ libs, pkgs, ... }: {
	environment.systemPackages = [ pkgs.unstable.libinput ];

	programs.hyprland = {
		enable = true;
		xwayland.enable = true;
	};

	security.pam.services.hyprlock = {};
}
