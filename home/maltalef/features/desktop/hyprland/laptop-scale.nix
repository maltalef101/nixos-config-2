# Escala del eDP a 1.25 mientras haya un monitor externo, 1 cuando está solo
# (ver pkgs/scripts/hypr-laptop-scale). Solo para hosts con panel de laptop.
{ pkgs, ... }: {
	home.packages = [ pkgs.hypr-laptop-scale ];

	wayland.windowManager.hyprland.settings.exec-once = [ "hypr-laptop-scale" ];
}
