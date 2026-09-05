{ pkgs ? import <nixpkgs> { } }: rec {
	maimfull = pkgs.callPackage ./scripts/maimfull { };
	hyprshot-full = pkgs.callPackage ./scripts/hyprshot-full { };
	hyprshot-region = pkgs.callPackage ./scripts/hyprshot-region { };
	hyprlock-lock = pkgs.callPackage ./scripts/hyprlock-lock { };
	hypr-merge-rogues = pkgs.callPackage ./scripts/hypr-merge-rogues { };
	start-hyprland-login = pkgs.callPackage ./scripts/start-hyprland-login { };
}
