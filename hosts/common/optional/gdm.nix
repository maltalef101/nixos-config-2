{ pkgs, lib, ... }: {
	services.displayManager.gdm = {
		enable = true;
		wayland = true;
	};
}
