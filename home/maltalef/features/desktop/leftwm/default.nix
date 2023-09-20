{ pkgs, ... }: {
	imports = [
	  ../common-x11
	  ./startx
	];

	home.packages = with pkgs; [ leftwm polybar ];
	home.file.".config/leftwm" = {
		source = ./config;
		recursive = true;
	};

	xsession = {
		enable = true;
		windowManager.command = "${pkgs.leftwm}/bin/leftwm";
	};
}
