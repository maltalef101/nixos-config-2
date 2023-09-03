{ lib, writeShellApplication, alacritty, pulsemixer }: (writeShellApplication {
  name = "volume";
  runtimeInputs = [ alacritty, pulsemixer ];
  text = builtins.readFile ./volume;
}) // {
  meta = with lib; {
    description = "Alacritty & Pulsemixer helper script";
    platforms = platforms.all;
  };
}
