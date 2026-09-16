{ pkgs, config, ... }:
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
	# wl-clipboard copia (también lo necesita pass -c); fuzzel es el backend
	# de tessen y también el launcher (fuzzel.nix) — queda acá igual para
	# que este módulo se valga solo.
	home.packages = [
		tessen-guarded
		pkgs.fuzzel
		pkgs.wl-clipboard

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
	# (fuzzel.nix): mismos colores, borde y radio, así los dos menúes se ven
	# iguales.
	xdg.configFile."tessen/fuzzel.ini".text = ''
    [main]
    font=FiraCode Nerd Font:pixelsize=13
    lines=12
    width=45
    horizontal-pad=14
    vertical-pad=10

    [colors]
    background=1d2021ff
    text=fbf1c7ff
    match=d8a657ff
    selection=7daea3ff
    selection-text=1d2021ff
    selection-match=1d2021ff
    border=fbf1c71f

    [border]
    width=1
    radius=8

    # custom-N imprime la selección y sale con código 10+N-1; tessen mapea
    # 15 a copiar el password y 18 a copiar el OTP, así Enter copia el
    # password directo desde el primer menú y Ctrl+Enter (execute, exit 0)
    # abre el menú de campos de siempre (user/otp/url/...). Los custom de
    # autotype (exit 10-12 y 17) quedan desmapeados: no hay wtype.
    [key-bindings]
    execute=Control+Return
    custom-6=Return KP_Enter
    custom-9=Control+o
    custom-1=none
    custom-2=none
    custom-3=none
    custom-8=none
  '';
}
