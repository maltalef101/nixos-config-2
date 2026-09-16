{ lib, writeShellApplication, jq }:
# hyprctl no va en runtimeInputs: tiene que ser el del hyprland corriendo
# (el del flake, en el PATH de la sesión), no el de nixpkgs.
(writeShellApplication {
  name = "hypr-cycle-monitor";
  runtimeInputs = [ jq ];
  text = builtins.readFile ./hypr-cycle-monitor;
}) // {
  meta = with lib; {
    description = "Cycle focus or move the active window across monitors in spatial (column) order";
    platforms = platforms.linux;
  };
}
