{ pkgs, lib, ... }: {
	services.displayManager.sddm = {
		enable = true;
		wayland = true;
		theme = "catpuccin";
	};

	environment.systemPackages =  [
		pkgs.catpuccin-sddm
	];
}
