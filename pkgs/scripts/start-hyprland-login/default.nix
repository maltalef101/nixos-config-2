{ lib, writeShellApplication, zsh }:
(writeShellApplication {
  name = "start-hyprland-login";
  # start-hyprland se resuelve recién en el PATH del login shell (perfil
  # del usuario), no acá: cada usuario arrastra su propio hyprland
  runtimeInputs = [ zsh ];
  text = builtins.readFile ./start-hyprland-login;
}) // {
  meta = with lib; {
    description = "Session launcher that routes start-hyprland through a login shell so hm-session-vars reach the graphical session";
    mainProgram = "start-hyprland-login";
    platforms = platforms.linux;
  };
}
