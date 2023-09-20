{ lib, writeShellApplication, makeWrapper, maim, xclip }:
(writeShellApplication {
  name = "maimsel";
  runtimeInputs = [ maim xclip ];
  text = builtins.readFile ./maimsel;
}) // {
  meta = with lib; {
    description = "Maim helper script";
    platforms = platforms.all;
  };
}
