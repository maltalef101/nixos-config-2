{ lib, writeShellApplication, makeWrapper, hyprshot }:
(writeShellApplication {
  name = "hyprshot-full";
  runtimeInputs = [ hyprshot ];
  text = builtins.readFile ./hyprshot-full;
}) // {
  meta = with lib; {
    description = "Hyprshot full-screen screenshot helper script";
    platforms = platforms.all;
  };
}
