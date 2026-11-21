# La distribución de pantallas por estación (ver pkgs/scripts/hypr-pantallas):
# un menú de fuzzel con F7 (XF86Display, la tecla de pantallas del ThinkPad) o
# $mod+o, y un vigía que reaplica lo elegido para cada estación al enchufarla.
# También escala el eDP a 1.25 mientras haya un externo prendido, 1 cuando está
# solo. Solo para hosts con panel de laptop.
{ pkgs, lib, config, ... }: {
	options.pantallas.monitores = lib.mkOption {
		type = with lib.types; listOf (attrsOf str);
		default = [ ];
		example = [ { desc = "ASR CL25FFA"; lugar = "derecha"; modo = "1920x1080@120"; } ];
		description = ''
			Lo que vale para un externo mientras su estación no tenga nada elegido en
			el menú. Gana la primera entrada que coincida, por `desc` (prefijo de la
			descripción) o por `puerto`. `lugar`: arriba, abajo, izquierda, derecha o
			apagado; `espejo`: puerto o prefijo de descripción del monitor a espejar
			(o "laptop"), con `lugar` para cuando no está; `modo`: WxH@Hz (si no, el
			máximo).
		'';
	};

	config = {
		home.packages = [ pkgs.hypr-pantallas ];

		xdg.configFile."hypr-pantallas/monitores.json".text = builtins.toJSON config.pantallas.monitores;

		wayland.windowManager.hyprland.settings = {
			exec-once = [ "hypr-pantallas --vigilar" ];
			bind = [
				", XF86Display, exec, hypr-pantallas"
				"$mod, o, exec, hypr-pantallas"
			];
		};
	};
}
