{ pkgs, config, lib, ... }:
let
	# pass sin terminal: tessen sobre fuzzel. El override mete el pass del
	# profile (con pass-otp) en el wrapper de tessen, que si no antepone al
	# PATH un pass pelado y rompe el campo otp.
	tessen = pkgs.tessen.override { pass = config.programs.password-store.package; };

	# el listener de clipse (clipse.nix) guarda en texto plano todo lo que
	# pase por el clipboard, incluidos los secretos que copia tessen (que
	# como corre sobre una layer de fuzzel es invisible para el filtro
	# excludedApps de clipse). Este wrapper para el listener antes y programa
	# la vuelta con un timer transiente: 50s cubre el clear de pass (45s
	# default) y, como el watcher captura el clipboard vigente al arrancar,
	# recién ahí es seguro relanzarlo. Correr tessen de nuevo antes de que
	# venza resetea el countdown (se pisa la unit clipse-resume).
	tessen-guarded = pkgs.writeShellScriptBin "tessen" ''
		systemctl --user stop clipse-resume.timer 2>/dev/null
		systemctl --user stop clipse.service 2>/dev/null
		${tessen}/bin/tessen "$@"
		rc=$?
		systemd-run --user --collect --on-active=50 --unit=clipse-resume \
			systemctl --user start clipse.service 2>/dev/null
		exit $rc
	'';
in {
	# wl-clipboard copia (también lo necesita pass -c); wtype tipea (autotype,
	# no pasa por el clipboard); fuzzel es el backend de tessen y también el
	# launcher (fuzzel.nix) — queda acá igual para que este módulo se valga
	# solo.
	home.packages = [
		tessen-guarded
		pkgs.fuzzel
		pkgs.wl-clipboard
		pkgs.wtype

		# escanea un QR en pantalla y agrega la URI otpauth:// a una entrada
		# existente; después aparece como campo "otp" acá y en pass otp
		pkgs.pass-otp-add
	];

	# action="copy" saca el menú de acción (¿autotype o copy?); fuzzel y no
	# wofi porque soporta exit codes custom, que tessen mapea a acciones
	# directas desde el primer menú (ver key-bindings del ini de abajo).
	# Ojo: indentar con espacios, el '' de nix no despega tabs y el parser
	# de tessen exige las claves al inicio de línea.
	xdg.configFile."tessen/config".text = ''
    dmenu_backend="fuzzel"
    action="copy"
    fuzzel_config_file="${config.xdg.configHome}/tessen/fuzzel.ini"
  '';

	# config de fuzzel exclusiva de tessen (vía fuzzel_config_file, no pisa
	# un eventual ~/.config/fuzzel). Apariencia calcada del launcher
	# (fuzzel.nix): la fuente y los colores salen de su config, y el mismo
	# borde y radio, así los dos menúes se ven iguales.
	xdg.configFile."tessen/fuzzel.ini".text = ''
    [main]
    font=${config.programs.fuzzel.settings.main.font}
    lines=12
    width=45
    horizontal-pad=14
    vertical-pad=10

    ${lib.generators.toINI { } { inherit (config.programs.fuzzel.settings) colors; }}
    [border]
    width=1
    radius=8

    # custom-N imprime la selección y sale con código 10+N-1; tessen mapea
    # 15 a copiar el password y 18 a copiar el OTP, así Enter copia el
    # password directo desde el primer menú y Ctrl+Enter (execute, exit 0)
    # abre el menú de campos de siempre (user/otp/url/...). Los de autotype
    # tipean con wtype en la ventana que queda con foco al cerrar fuzzel:
    # Alt+Enter la secuencia (campo autotype: de la entrada, o user ⇥ pass),
    # Alt+u el user, Alt+p el password, Alt+o el OTP.
    [key-bindings]
    execute=Control+Return
    custom-6=Return KP_Enter
    custom-9=Control+o
    custom-1=Mod1+Return
    custom-2=Mod1+u
    custom-3=Mod1+p
    custom-8=Mod1+o
  '';
}
