{ pkgs ? import <nixpkgs> { } }: rec {
	maimfull = pkgs.callPackage ./scripts/maimsel { };
	maimsel = pkgs.callPackage ./scripts/maimfull { };
	hyprshot-full = pkgs.callPackage ./scripts/hyprshot-full { };
	hyprshot-region = pkgs.callPackage ./scripts/hyprshot-region { };
	# notify-battery-status = pkgs.callPackage ./scripts/notify-battery-status { };
}
