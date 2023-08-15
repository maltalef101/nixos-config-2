{ pkgs, config, ... }: {
	users.mutableUsers = false;
	users.users.misterio = {
		isNormalUser = true;
		shell = pkgs.nushell;
		extraGroups = [ "wheel" "video" "audio" ];
	};

	services.geoclue2.enable = true;
}
