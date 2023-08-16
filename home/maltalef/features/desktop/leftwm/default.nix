{ pkgs, ... }: {
	imports = [
	  ../common
	];
	home.packages = with pkgs; [ leftwm polybar ];
	home.file.".config/leftwm" = {
		source = ./config;
		recursive = true;
	};
}
