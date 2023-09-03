{ lib, pkgs, stdenv, makeWrapper, maim, xclip }: with lib; {
	stdenv.mkDerivation = {
		name = "maimfull";
		version = "1.0";
		src = ./maimfull;

		nativeBuildInputs = [ makeWrapper ];
		dontUnpack = true;
		dontBuild = true;
		dontConfigure = true;

		installPhase = ''
		  install -Dm 0755 $src $out/bin/maimfull
		  wrapProgram $out/bin/maimfull --set PATH \
		    "${ makeBinPath [ maim xclip ] }"
		'';

		meta = {
			description = "Maim helper script";
			platforms = platforms.all;
		};
	};
}
