{ lib, pkgs, stdenv, makeWrapper, maim, xclip }: with lib; {
	stdenv.mkDerivation = {
		name = "maimsel";
		version = "1.0";
		src = ./maimsel;

		nativeBuildInputs = [ makeWrapper ];
		dontUnpack = true;
		dontBuild = true;
		dontConfigure = true;

		installPhase = ''
		  install -Dm 0755 $src $out/bin/maimsel
		  wrapProgram $out/bin/maimsel --set PATH \
		    "${ makeBinPath [ maim xclip ] }"
		'';

		meta = {
			description = "Maim helper script";
			platforms = platforms.all;
		};
	};
}
