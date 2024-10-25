{ lib, writeShellApplication, makeWrapper, hyprshot }:
(writeShellApplication {
  name = "hyprshot-region";
  runtimeInputs = [ hyprshot ];
  text = builtins.readFile ./hyprshot-region;
}) // {
  meta = with lib; {
    description = "Hyprshot region screenshot helper script";
    platforms = platforms.all;
  };
}
