{ pkgs ? import <nixpkgs> { } }: rec {
	maimfull = pkgs.callPackage ./scripts/maimsel { };
	maimsel = pkgs.callPackage ./scripts/maimfull { };
}
