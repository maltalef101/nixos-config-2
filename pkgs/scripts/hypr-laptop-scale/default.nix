{ lib, writeShellApplication, jq, socat, gawk }:
(writeShellApplication {
  name = "hypr-laptop-scale";
  # hyprctl no va en runtimeInputs: tiene que ser el del hyprland corriendo
  # (el del flake, en el PATH de la sesión), no el de nixpkgs.
  runtimeInputs = [ jq socat gawk ];
  text = builtins.readFile ./hypr-laptop-scale;
}) // {
  meta = with lib; {
    description = "Scale the laptop panel to 1.25 while an external monitor is connected, back to 1 when alone";
    platforms = platforms.linux;
  };
}
