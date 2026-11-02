{ pkgs, config, osConfig, lib, ...}:
let
	tema = config.tema;

	# "rrggbb" -> "r, g, b", para rgba() (swaync mismo arma
	# rgba(var(--noti-bg), alfa))
	rgb = hex: lib.concatMapStringsSep ", "
		(i: toString (lib.fromHexString (builtins.substring i 2 hex))) [ 0 2 4 ];

	# un glifo de Font Awesome (en la Nerd Font) por su código: Figtree no
	# los tiene y fontconfig cae en FiraCode Nerd Font
	glifo = codigo: builtins.fromJSON ''"\u${codigo}"'';

	swayncClient = "${config.services.swaync.package}/bin/swaync-client";
	systemctl = "${osConfig.systemd.package}/bin/systemctl";
	krb5 = pkgs.krb5;

	# Botones del centro. swaync corre `command` al hacer clic y, en un
	# conmutador, `update-command` cada vez que se abre el centro (nada de
	# polling): `estado` sale 0 si está prendido, y el clic corre `prender` o
	# `apagar` según el estado nuevo (SWAYNC_TOGGLE_STATE).
	conmutador = nombre: { etiqueta, estado, prender, apagar }: {
		label = etiqueta;
		type = "toggle";
		command = "${pkgs.writeShellScript "swaync-${nombre}" ''
			if [ "$SWAYNC_TOGGLE_STATE" = true ]; then
				${prender}
			else
				${apagar}
			fi
		''}";
		update-command = "${pkgs.writeShellScript "swaync-${nombre}-estado" ''
			if ${estado}; then echo true; else echo false; fi
		''}";
	};
	# un botón que cierra el centro y corre `guion` (la captura, el bloqueo)
	accion = nombre: etiqueta: guion: {
		label = etiqueta;
		command = "${pkgs.writeShellScript "swaync-${nombre}" ''
			${swayncClient} -cp
			${guion}
		''}";
	};

	# La VPN y el padrón del sistema, si su configuración los tiene (los módulos del input infra, en pirincho); si no,
	# sin esos botones
	vpn = lib.attrByPath [ "chaska" "vpnInfra" ] { enable = false; } osConfig;
	padron = lib.attrByPath [ "chaska" "padron" ] { enable = false; } osConfig;
	nmcli = "${osConfig.networking.networkmanager.package}/bin/nmcli";
	bluetoothctl = "${osConfig.hardware.bluetooth.package}/bin/bluetoothctl";

	# un ticket del padrón para la persona, en una ventana flotante chica (la
	# windowrule de appIdTicket, abajo) que se cierra al terminar: con
	# armadura (FAST, que el OTP pide). Con chaska.ch, `ch ticket sacar`: la
	# armadura con la raíz de IPA del checkout de infra como ancla de PKINIT,
	# y la contraseña (oculta) y el código (visible) en campos aparte, que
	# lee de la terminal (sin terminal no corre). `ch` es python3 y sus
	# guiones, bash con kinit y klist del PATH: van al final por si el de
	# swaync no los trae. Sin chaska.ch, kinit con armadura anónima, que los
	# pide juntos.
	#
	# El resultado, en una notificación: hasta cuándo vale el ticket, o el
	# motivo del fallo. stderr pasa por tee para quedarse con el motivo (lo
	# de muere, «ch ticket: …», o la última línea de kinit) y se ve igual en
	# la ventana; las preguntas van por ahí, pero lo tipeado no (lo muestra
	# la terminal, o nada si es la contraseña).
	principal = "${config.home.username}@${padron.reino}";
	ch = "${config.home.homeDirectory}/.local/bin/ch";
	appIdTicket = "ticket-padron";
	notifySend = "${pkgs.libnotify}/bin/notify-send --app-name=Kerberos";
	sacarTicket = if lib.attrByPath [ "chaska" "ch" "enable" ] false config then ''
		export PATH="$PATH:${lib.makeBinPath [ krb5 pkgs.python3 pkgs.bash pkgs.coreutils pkgs.gnugrep ]}"
		sacar() { ${ch} ticket sacar; }
	'' else ''
		arm="$XDG_RUNTIME_DIR/krb5cc_armadura"
		trap '${krb5}/bin/kdestroy -q -c "$arm" 2>/dev/null' EXIT
		sacar() {
			echo "La contraseña y, si te lo pide, el token, juntos."
			${krb5}/bin/kinit -n -c "$arm" && ${krb5}/bin/kinit -T "$arm" ${principal}
		}
	'';
	kinitPadron = pkgs.writeShellScript "ticket-padron" ''
		${sacarTicket}
		echo "Ticket del padrón para ${principal}"
		# pipefail: el estado es el de sacar, no el de tee
		err=$(set -o pipefail; sacar 2>&1 >/dev/tty | ${pkgs.coreutils}/bin/tee /dev/tty)
		if [ $? -eq 0 ]; then
			# LC_ALL=C: las fechas de klist en mm/dd/yy, que date entiende
			hasta=$(LC_ALL=C ${krb5}/bin/klist | ${pkgs.gawk}/bin/awk '$5 ~ /^krbtgt\// { print $3, $4; exit }')
			hasta=$(${pkgs.coreutils}/bin/date -d "$hasta" +%H:%M 2>/dev/null) \
				&& ${notifySend} "Ticket del padrón vigente hasta $hasta" \
				|| ${notifySend} "Ticket del padrón sacado"
		else
			# la última línea, sin el «Detalle:» que muere pone después del
			# motivo. Las preguntas no terminan en salto de línea: lo que sigue
			# a la última queda en su misma línea, y se le saca
			motivo=$(printf '%s\n' "$err" \
				| ${pkgs.gnused}/bin/sed -E 's/^(Contraseña de |Código, |Password for )[^:]*: //; s/^ch ticket: //; /^Detalle: /d; /^[[:space:]]*$/d; /: $/d' \
				| ${pkgs.coreutils}/bin/tail -n 1)
			${notifySend} --urgency=critical "No se sacó el ticket del padrón" "''${motivo:-Se canceló.}"
		fi
	'';

	botones =
		lib.optional vpn.enable (conmutador "vpn-infra" {
			etiqueta = "${glifo "f132"}   VPN infra";
			estado = "${lib.getExe vpn.comando} estado >/dev/null";
			# lo mismo que `alternar`, pero hacia el estado que pidió el clic
			prender = "exec ${lib.getExe vpn.comando} arriba </dev/null";
			apagar = "exec ${lib.getExe vpn.comando} abajo";
		})
		++ lib.optional osConfig.networking.networkmanager.enable (conmutador "wifi" {
			etiqueta = "${glifo "f1eb"}   Wifi";
			estado = ''[ "$(${nmcli} radio wifi)" = enabled ]'';
			prender = "exec ${nmcli} radio wifi on";
			apagar = "exec ${nmcli} radio wifi off";
		})
		++ lib.optional osConfig.hardware.bluetooth.enable (conmutador "bluetooth" {
			etiqueta = "${glifo "f293"}   Bluetooth";
			estado = "${bluetoothctl} show | grep -q 'Powered: yes'";
			prender = "exec ${bluetoothctl} power on";
			apagar = "exec ${bluetoothctl} power off";
		})
		++ [
			(conmutador "no-molestar" {
				etiqueta = "${glifo "f1f6"}   No molestar";
				estado = ''[ "$(${swayncClient} -D)" = true ]'';
				prender = "exec ${swayncClient} -dn";
				apagar = "exec ${swayncClient} -df";
			})
		]
		# hyprsunset.nix: el servicio sigue el perfil del día; apagarlo deja
		# los colores neutros hasta prenderlo (o la próxima sesión)
		++ lib.optional config.services.hyprsunset.enable (conmutador "luz-nocturna" {
			etiqueta = "${glifo "f186"}   Luz nocturna";
			estado = "${systemctl} --user -q is-active hyprsunset.service";
			prender = "exec ${systemctl} --user start hyprsunset.service";
			apagar = "exec ${systemctl} --user stop hyprsunset.service";
		})
		# prendido: hay un ticket vigente (klist -s); el clic saca uno en una
		# ventana flotante o lo destruye
		++ lib.optional padron.enable (conmutador "kerberos" {
			etiqueta = "${glifo "f084"}   Kerberos";
			estado = "${krb5}/bin/klist -s";
			prender = ''
				${swayncClient} -cp
				exec ${lib.getExe config.programs.foot.package} --app-id=${appIdTicket} --title "Kerberos del padrón" ${kinitPadron}
			'';
			apagar = "exec ${krb5}/bin/kdestroy -q";
		})
		++ [
			# hide-on-action no vale para los botones: se cierra el centro y se
			# espera a que se vaya antes de la captura
			(accion "captura" "${glifo "f030"}   Captura" ''
				sleep 0.4
				exec ${lib.getExe' pkgs.hyprshot-region "hyprshot-region"}
			'')
			(accion "bloquear" "${glifo "f023"}   Bloquear"
				"exec ${lib.getExe' (pkgs.hyprlock-lock.override { hyprlock = config.programs.hyprlock.package; }) "hyprlock-lock"}")
		];

	# un botón de energía que cierra todo lo abierto: después de cerrar el
	# centro pregunta con una notificación (pasa el no molestar, no queda en
	# el centro, se va sola a los 10 s) y sigue sólo si se elige `boton`
	confirmada = nombre: etiqueta: { pregunta, detalle, icono, boton, guion }:
		accion nombre etiqueta ''
			r=$(${pkgs.libnotify}/bin/notify-send --app-name=Energía --icon=${icono} \
				--transient --expire-time=10000 --hint=boolean:SWAYNC_BYPASS_DND:true \
				--action=si=${lib.escapeShellArg boton} --action=no=Cancelar --wait \
				${lib.escapeShellArg pregunta} ${lib.escapeShellArg detalle})
			[ "$r" = si ] || exit 0
			${guion}
		'';

	# La fila de energía, sólo íconos (swaync no pone tooltips en sus botones):
	# suspender va directo; cerrar la sesión, reiniciar y apagar cierran todo
	# lo abierto, así que preguntan antes
	energia = [
		(accion "suspender" (glifo "f236") "exec ${systemctl} suspend")
		(confirmada "salir" (glifo "f08b") {
			pregunta = "¿Cerrar la sesión?";
			detalle = "Se cierran todas las ventanas.";
			icono = "system-log-out";
			boton = "Cerrar la sesión";
			guion = "exec ${config.wayland.windowManager.hyprland.finalPackage}/bin/hyprctl dispatch exit";
		})
		(confirmada "reiniciar" (glifo "f01e") {
			pregunta = "¿Reiniciar?";
			detalle = "Se cierran todas las ventanas y el equipo vuelve a arrancar.";
			icono = "system-reboot";
			boton = "Reiniciar";
			guion = "exec ${systemctl} reboot";
		})
		(confirmada "apagar" (glifo "f011") {
			pregunta = "¿Apagar?";
			detalle = "Se cierran todas las ventanas y el equipo se apaga.";
			icono = "system-shutdown";
			boton = "Apagar";
			guion = "exec ${systemctl} poweroff";
		})
	];

	# El centro con el tema (pirincho): primero las notificaciones (se
	# estiran hasta los controles), con quién las silencia justo abajo; después
	# lo que suena, el volumen y el brillo; los conmutadores, y al pie, de lado
	# a lado, la fila de energía.
	centro = {
		positionX = "right";
		positionY = "top";
		layer = "overlay";
		control-center-layer = "overlay";
		control-center-margin-top = 8;
		control-center-margin-bottom = 8;
		control-center-margin-right = 8;
		control-center-width = 440;
		notification-window-width = 420;
		fit-to-screen = true;

		timeout = 8;
		timeout-low = 4;
		timeout-critical = 0;
		notification-icon-size = 48;
		notification-body-image-height = 120;
		notification-body-image-width = 240;
		notification-inline-replies = true;
		notification-grouping = true;
		relative-timestamps = true;
		image-visibility = "when-available";
		transition-time = 200;
		keyboard-shortcuts = true;
		hide-on-clear = false;
		hide-on-action = true;
		script-fail-notify = true;
		text-empty = "Sin notificaciones";

		widgets = [ "title" "notifications" "inhibitors" "mpris" "volume" "backlight" "buttons-grid" "buttons-grid#energia" ];
		widget-config = {
			title = {
				text = "Notificaciones";
				clear-all-button = true;
				button-text = "Limpiar todo";
			};
			buttons-grid = {
				buttons-per-row = 3;
				actions = botones;
			};
			# otra grilla, de una fila: toma el estilo de los conmutadores
			"buttons-grid#energia" = {
				buttons-per-row = 4;
				actions = energia;
			};
			volume = {
				label = glifo "f028";
				show-per-app = true;
				show-per-app-icon = true;
				show-per-app-label = true;
				expand-button-label = glifo "f107";
				collapse-button-label = glifo "f106";
				empty-list-label = "Nada suena";
			};
			# el panel de pirincho (ls /sys/class/backlight); swaync lo cambia
			# por logind, sin root
			backlight = {
				label = glifo "f185";
				device = "amdgpu_bl1";
			};
			mpris = {
				show-album-art = "when-available";
				autohide = true;
			};
			# las apps que callan las notificaciones (swaync-client -Ia), no
			# las que impiden la suspensión; sin ninguna no se ve
			inhibitors = {
				text = "Silenciadas por";
				clear-all-button = true;
				button-text = "Soltar todas";
			};
			notifications.vexpand = true;
		};
	};
in {
	# notify-send: antes lo traía dunst.nix (retirado); swaync es ahora el
	# único stack de notificaciones, así que provee él el cliente.
	home.packages = [ pkgs.libnotify ];

	# la ventana del botón Kerberos: chica, centrada, fuera del tiling
	wayland.windowManager.hyprland.settings.windowrule = lib.mkIf padron.enable [
		"float on, size 560 200, center on, match:class ^(${appIdTicket})$"
	];

	# Al activar home-manager, recargar config y css en vez de reiniciar: el
	# reinicio pierde el historial de notificaciones y el no molestar. Un
	# swaync nuevo entra en la próxima sesión.
	systemd.user.services.swaync = {
		Unit.X-SwitchMethod = "reload";
		Service.ExecReload = [
			"${config.services.swaync.package}/bin/swaync-client --reload-config"
			"${config.services.swaync.package}/bin/swaync-client --reload-css"
		];
	};

	services.swaync = {
		enable = true;

		# Con el tema (pirincho): swaync carga su hoja por omisión y
		# después esta, que pone sus variables en la paleta del tema y viste
		# las tarjetas, el centro y sus widgets como fuzzel y hyprlock (radio
		# 8, campo, el acento para lo prendido y lo seleccionado, las
		# críticas con el borde de error, la fuente de interfaz). Sin el tema, la hoja por omisión sola, como siempre. El
		# style.css de este directorio no se usa (nunca se conectó).
		style = lib.mkIf tema.enable (with tema.colores; ''
			:root {
				--cc-bg: rgba(${rgb fondo}, 0.94);
				--noti-border-color: rgba(${rgb texto}, 0.10);
				--noti-bg: ${rgb superficie};
				--noti-bg-alpha: 0.97;
				--noti-bg-darker: #${fondoHondo};
				--noti-bg-alt: #${fondoHondo};
				--noti-bg-hover: #${campo};
				--noti-bg-focus: rgba(${rgb campo}, 0.3);
				--noti-close-bg: rgba(${rgb texto}, 0.08);
				--noti-close-bg-hover: #${campoHover};
				--text-color: #${texto};
				--text-color-disabled: #${textoTenue};
				--bg-selected: #${acento};
				--border-radius: 8px;
				--notification-icon-size: 48px;
				--notification-group-icon-size: 24px;
				--notification-shadow: 0 2px 8px rgba(${rgb fondoHondo}, 0.6);
				--font-size-summary: 14px;
				--font-size-body: 13px;
				--hover-transition: background 150ms ease-out, color 150ms ease-out;
				--mpris-album-art-overlay: rgba(${rgb fondoHondo}, 0.65);
				--mpris-button-hover: rgba(${rgb acento}, 0.4);
				--mpris-album-art-icon-size: 64px;
				--mpris-album-art-shadow: none;
				--widget-volume-row-icon-size: 20px;
			}

			* {
				font-family: "${tema.fuentes.interfaz}", "FiraCode Nerd Font";
			}

			/* Las tarjetas */
			.notification-row .notification-background {
				padding: 6px 10px;
			}

			.notification-row .notification-background .notification {
				border: 1px solid var(--noti-border-color);
				box-shadow: var(--notification-shadow);
			}

			.floating-notifications .notification {
				box-shadow: var(--notification-shadow);
			}

			.notification-row .notification-background .notification.low {
				opacity: 0.85;
			}

			.notification-row .notification-background .notification.critical {
				border-color: #${errorBorde};
				box-shadow: inset 3px 0 #${errorBorde}, var(--notification-shadow);
			}

			.notification-row .notification-background .notification .notification-default-action {
				padding: 8px;
			}

			.notification-content .text-box .summary {
				font-weight: 600;
			}

			.notification-content .text-box .time {
				font-size: 12px;
				font-weight: normal;
				color: #${textoTenue};
			}

			/* El cuerpo con el texto pleno, como el título (que se distingue
			   por el peso): con el tenue quedaba en 6,8:1 y, en las de baja
			   urgencia (0.85 de opacidad), cerca de 4,5:1 sobre un fondo
			   claro. checks.tema mide el contraste. */
			.notification-content .text-box .body {
				color: #${texto};
			}

			.notification-content .app-icon {
				-gtk-icon-shadow: none;
			}

			.notification-content .inline-reply .inline-reply-entry {
				background: #${campo};
				border-color: transparent;
			}

			.notification-content .inline-reply .inline-reply-entry:focus-within {
				border-color: #${foco};
			}

			.notification-action > button {
				background: #${campo};
				border: none;
				box-shadow: none;
				transition: var(--hover-transition);
			}

			.notification-action > button:hover {
				background: #${acento};
				color: #${sobreAcento};
			}

			.close-button {
				margin-top: 10px;
				margin-right: 10px;
			}

			.close-button:hover {
				background: #${errorBorde};
				color: #${sobreAcento};
			}

			/* Agrupadas por app */
			.notification-group .notification-group-headers .notification-group-header {
				font-weight: 600;
				color: #${textoTenue};
			}

			.notification-group.collapsed.not-expanded {
				opacity: 0.5;
			}

			/* El centro */
			.control-center {
				border: 1px solid var(--noti-border-color);
				border-radius: 12px;
				box-shadow: var(--notification-shadow);
			}

			.control-center .control-center-list-placeholder {
				color: #${textoTenue};
				opacity: 0.7;
			}

			.widget {
				margin: 6px 10px;
			}

			.widget-title > label {
				font-size: 1.3rem;
				font-weight: 600;
			}

			/* Las notificaciones arriba (se estiran, vacías o no) y una raya
			   que las separa de los controles de abajo */
			.widget-notifications {
				padding-bottom: 6px;
				border-bottom: 1px solid var(--noti-border-color);
				border-radius: 0;
			}

			.widget-title > button,
			.widget-inhibitors > button {
				background: #${campo};
				color: #${texto};
				border: none;
				box-shadow: none;
				padding: 4px 12px;
				border-radius: var(--border-radius);
				transition: var(--hover-transition);
			}

			.widget-title > button:hover,
			.widget-inhibitors > button:hover {
				background: #${acento};
				color: #${sobreAcento};
			}

			.widget-inhibitors > label {
				font-size: 1rem;
				font-weight: 600;
				color: #${textoTenue};
			}

			/* Los conmutadores: campo apagados, el morado de la marca prendidos */
			.widget-buttons-grid {
				padding: 0;
			}

			.widget-buttons-grid flowboxchild {
				padding: 3px;
			}

			.widget-buttons-grid flowboxchild > button {
				background: #${campo};
				color: #${texto};
				border: none;
				box-shadow: none;
				min-height: 40px;
				padding: 0 10px;
				transition: var(--hover-transition);
			}

			.widget-buttons-grid flowboxchild > button:hover {
				background: #${campoHover};
			}

			.widget-buttons-grid flowboxchild > button.toggle:checked,
			.widget-buttons-grid flowboxchild > button.active {
				background: #${acento};
				color: #${sobreAcento};
			}

			.widget-buttons-grid flowboxchild > button label {
				font-size: 13px;
			}

			/* Volumen, por app, y brillo */
			.widget-volume,
			.widget-backlight {
				background: #${superficie};
				padding: 6px 10px;
			}

			.widget-volume > box > label,
			.widget-backlight > label {
				font-size: 16px;
				min-width: 24px;
			}

			.widget-volume button {
				background: transparent;
				border: none;
				box-shadow: none;
			}

			.widget-volume button:hover {
				background: #${campo};
			}

			scale trough {
				background: #${campo};
				border-radius: 999px;
				min-height: 6px;
			}

			scale highlight {
				background: #${acento};
				border-radius: 999px;
			}

			scale slider {
				background: #${texto};
				border: none;
				box-shadow: none;
				min-width: 14px;
				min-height: 14px;
				border-radius: 999px;
			}

			.per-app-volume {
				padding: 4px;
			}

			/* Lo que suena */
			.widget-mpris .widget-mpris-player {
				margin: 6px 10px;
				box-shadow: none;
			}

			.widget-mpris .widget-mpris-player .mpris-overlay {
				padding: 12px;
			}

			.widget-mpris .widget-mpris-player .mpris-overlay .widget-mpris-title {
				font-size: 1.1rem;
				font-weight: 600;
			}

			.widget-mpris .widget-mpris-player .mpris-overlay .widget-mpris-subtitle {
				font-size: 0.95rem;
				color: #${textoTenue};
			}

			/* La fila de energía, al pie: los botones de la grilla, sólo con
			   el ícono, un poco más grande */
			.widget-buttons-grid.energia {
				margin-top: 0;
			}

			.widget-buttons-grid.energia flowboxchild > button label {
				font-size: 16px;
			}
		'');

		settings = if tema.enable then centro else {
# 			positionX = "right";
# 			positionY = "top";
# 			control-center-positionX = "none";
# 			control-center-positionY = "none";
# 			control-center-margin-top = 8;
# 			control-center-margin-bottom = 8;
# 			control-center-margin-right = 8;
# 			control-center-margin-left = 8;
# 			layer-shell-cover-screen = true;
#
# 			layer-shell = true;
# 			layer = "overlay";
# 			control-center-layer = "overlay";
# 			notification-body-image-height = 100;
# 			notification-body-image-width = 100;
# 			notification-inline-replies = true;
# 			timeout = 10;
# 			timeout-low = 5;
# 			timeout-critical = 0;
# 			notification-window-width = 500;
# 			keyboard-shortcuts = true;
# 			image-visibility = "always";
# 			transition-time = 200;
# 			hide-on-clear = true;
# 			hide-on-action = true;
# 			script-fail-notify = true;
#
 			widgets = [ "title" "dnd" "mpris" "notifications" "volume" "backlight" ];
# 			widget-config = {
# 				notifications = {
# 					vexpand = true;
# 				};
#
 				title = {
 					text = "Notifications";
 					clear-all-button = true;
 					button-text = "Clear All";
 				};
#
# 				dnd.text = "Do Not Disturb";
#
# 				label = {
# 					max-lines = 5;
# 					text = "Label Text";
# 				};
#
# 				mpris.autohide = true;
#
# 				volume = {
# 					label = "📣";
# 					show-per-app = true;
# 					show-per-app-icon = true;
# 				};
#
# 				backlight = {
# 					label = "☀️";
# 				};
# 			};
 		};
	};
}
