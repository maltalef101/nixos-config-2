{ lib, writeShellApplication, makeWrapper, maim, xclip }:
(writeShellApplication {
  name = "maimfull";
  runtimeInputs = [ maim xclip ];
  text = builtins.readFile ./maimfull;
  }) // {
  meta = with lib; {
    description = "Maim helper script";
    platforms = platforms.all;
  };
}
