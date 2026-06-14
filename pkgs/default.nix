{ pkgs ? import <nixpkgs> { } }: rec {
	maimfull = pkgs.callPackage ./scripts/maimsel { };
	maimsel = pkgs.callPackage ./scripts/maimfull { };
	hyprshot-full = pkgs.callPackage ./scripts/hyprshot-full { };
	hyprshot-region = pkgs.callPackage ./scripts/hyprshot-region { };
}
