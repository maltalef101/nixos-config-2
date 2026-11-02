{ pkgs ? import <nixpkgs> { }, inputs ? { } }: rec {
	maimfull = pkgs.callPackage ./scripts/maimfull { };
	hyprshot-full = pkgs.callPackage ./scripts/hyprshot-full { };
	hyprshot-region = pkgs.callPackage ./scripts/hyprshot-region { };
	hyprlock-lock = pkgs.callPackage ./scripts/hyprlock-lock { };
	hypr-merge-rogues = pkgs.callPackage ./scripts/hypr-merge-rogues { };
	hypr-cycle-monitor = pkgs.callPackage ./scripts/hypr-cycle-monitor { };
	hypr-laptop-scale = pkgs.callPackage ./scripts/hypr-laptop-scale { };
	pass-otp-add = pkgs.callPackage ./scripts/pass-otp-add { };
	start-hyprland-login = pkgs.callPackage ./scripts/start-hyprland-login { };
	mdview = pkgs.callPackage ./scripts/mdview { };
	# src = input del flake (git+file al checkout en ~/dev); ver pkgs/claude-swap
	claude-swap = pkgs.callPackage ./claude-swap { src = inputs.claude-swap; };
}
