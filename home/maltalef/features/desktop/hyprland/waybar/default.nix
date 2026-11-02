{ pkgs, lib, config, ... }:
let
	tema = config.tema;

	# Con el tema (pirincho): los colores con nombre de la paleta
	# (gruvbox-verde: el aqua 689d6a) y su fuente de interfaz. Si no, gruvbox
	# y la fuente de foot. Las hojas hablan de la paleta para la que se
	# hicieron (islas.css da sus contrastes): no se tocan, para que con ella
	# el CSS siga byte a byte. Con gruvbox-verde, contra la isla (fondoHondo #141617 al 94 %, borde
	# #3c3836) el texto da ~13:1, el tenue ~8.3:1 y el acento ~5.7:1.
	colores = if tema.enable then with tema.colores; {
		background-color = superficie;
		foreground-color = texto;
		foreground-color-alt = textoClaro;
		primary = acento;
		on-primary = sobreAcento;
		alert = alerta;
		warning = aviso;
		# los de las islas (islas.css y espacios.css)
		inherit fondo campo foco ok;
		fondo-hondo = fondoHondo;
		texto-tenue = textoTenue;
	} else {
		background-color = "1d2021";
		foreground-color = "ebdbb2";
		foreground-color-alt = "fbf1c7";
		primary = "689d6a";
		on-primary = "1d2021";
		alert = "cc241d";
		warning = "fabd2f";
	};
	fuente = if tema.enable then tema.fuentes.interfaz else "FiraCode Nerd Font";

	# Con el tema, la barra es transparente y los módulos van en islas
	# por función (la variante B de docs/propuestas/waybar): workspaces |
	# ventana | reloj | estado (VPN, volumen, batería) | recursos |
	# bandeja + notificaciones. Un grupo `group/x` es la isla #x del CSS.
	# La red, sólo en el nm-applet de la bandeja; el módulo VPN, en vpn.nix.
	hojas = if tema.enable
		then [ ./islas.css ./espacios.css ]
		else [ ./style.css ];

	# Los íconos, emojis de Noto Color Emoji, como en la barra sin el tema: el
	# color del módulo (el aviso o la alerta del CSS) queda en el texto, y el
	# emoji con los suyos. Las métricas no tienen ancho fijo (ni min-length ni
	# relleno): cada isla mide lo que su texto, y cambia cuando un valor gana o
	# pierde una cifra.
	emoji = e: "<span font='Noto Color Emoji'>${e}</span>";

	islas = {
		height = 38;
		spacing = 0;

		modules-left = [ "group/espacios" "group/ventana" ];
		modules-center = [ "clock" ];
		modules-right = [ "group/estado" "group/recursos" "group/bandeja" ];

		"group/espacios" = {
			orientation = "horizontal";
			modules = [ "hyprland/workspaces" ];
		};

		"group/ventana" = {
			orientation = "horizontal";
			modules = [ "hyprland/window" ];
		};

		"group/estado" = {
			orientation = "horizontal";
			modules = [ "custom/vpn" "wireplumber" "battery" ];
		};

		"group/recursos" = {
			orientation = "horizontal";
			modules = [ "disk" "memory" "cpu" "temperature" ];
		};

		"group/bandeja" = {
			orientation = "horizontal";
			modules = [ "tray" "custom/notifications" ];
		};

		# (los workspaces vacíos que no se ven los esconde espacios.css)

		"hyprland/window" = {
			separate-outputs = true;
			icon = true;
			icon-size = 20;
			max-length = 30;
		};

		# el calendario del mes al pasar el puntero: el mes en el texto claro,
		# los días de la semana en tenue, hoy en el acento. (Los fines de
		# semana no: el calendario de waybar da formato por renglón, no por
		# columna.)
		clock = {
			timezone = "America/Argentina/Buenos_Aires";
			format = "{:%d/%m  %H:%M}";
			format-alt = "{:%A %d, %B  %H:%M:%S}";
			tooltip-format = "<tt>{calendar}</tt>";
			calendar = with tema.colores; {
				mode = "month";
				format = {
					months = "<span color='#${textoClaro}'><b>{}</b></span>";
					weekdays = "<span color='#${textoTenue}'>{}</span>";
					days = "<span color='#${texto}'>{}</span>";
					today = "<span color='#${acento}'><b><u>{}</u></b></span>";
				};
			};
			actions = {
				on-click = "mode";
				# la rueda pasa de mes en el calendario
				on-scroll-up = "shift_up";
				on-scroll-down = "shift_down";
			};
		};

		temperature = {
			# NOTE: this is is platform dependent
			thermal-zone = 6;
			format = "${emoji "🌡"} {temperatureC}°C";
			critical-threshold = 80;
		};

		cpu = {
			interval = 2;
			format = "${emoji "🪨"} {usage}%";
			states = {
				critical = 95;
			};
		};

		memory = {
			interval = 2;
			format = "${emoji "💾"} {percentage}%";
			states = {
				critical = 90;
			};
		};

		disk = {
			interval = 20;
			format = "${emoji "📂"} {percentage_used}%";
			states = {
				warning = 80;
				critical = 95;
			};
		};

		# la pila; crítica y descargándose, la pila baja; cargando, el enchufe
		battery = {
			interval = 20;
			states = {
				warning = 30;
				critical = 15;
			};
			format = "${emoji "{icon}"} {capacity}%";
			format-icons = {
				default = "🔋";
				discharging-critical = "🪫";
				charging = "🔌";
			};
			format-time = "{H} h {m} min";
			tooltip-format-discharging = "{capacity} %: quedan {time}\n{power:.1f} W";
			tooltip-format-charging = "{capacity} %: carga completa en {time}\n{power:.1f} W";
			tooltip-format-plugged = "{capacity} %, enchufada";
			tooltip-format-full = "cargada, enchufada";
		};

		# rueda: ±4 % como las teclas de volumen; clic: silenciar; clic
		# derecho: pavucontrol
		wireplumber = {
			format = "${emoji "{icon}"} {volume}%";
			format-muted = "${emoji "🔇"} {volume}%";
			format-icons = [ "🔈" "🔉" "🔊" ];
			tooltip-format = "{node_name}: {volume} %";
			scroll-step = 4;
			max-volume = 100;
			on-click = "${pkgs.wireplumber}/bin/wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
			on-click-right = "${pkgs.pavucontrol}/bin/pavucontrol";
		};

		"custom/notifications" = {
			tooltip = false;
			format = "${emoji "{icon}"} {text}";
			format-icons = {
				notification = "🔔<sup>❕</sup>";
				none = "🔔";
				dnd-notification = "🔕<sup>❕</sup>";
				dnd-none = "🔕";
				inhibited-notification = "🔕<sup>❕</sup>";
				inhibited-none = "🔕";
				dnd-inhibited-notification = "🔕<sup>❕</sup>";
				dnd-inhibited-none = "🔕";
			};

			return-type = "json";
			exec-if = "which swaync-client";
			exec = "swaync-client -swb";
			on-click = "swaync-client -t -sw";
			on-click-right = "swaync-client -d -sw";
			escape = true;
		};
	};

	# hyprsplit numera por monitor (1-10, 11-20, ...); acá se muestran
	# todos como 1-10
	numeros = builtins.listToAttrs (builtins.concatLists (builtins.genList (m:
		builtins.genList (i: {
			name = toString (m * 10 + i + 1);
			value = toString (i + 1);
		}) 10
	) 3));
in {
	imports = [ ./vpn.nix ];

	programs.waybar = {
		enable = true;

		# (strings con "" y no con '': el '' de nix no despega tabs)
		style = builtins.concatStringsSep "\n" (
			pkgs.lib.mapAttrsToList (nombre: color: "@define-color ${nombre} #${color};") colores
			++ [ "" "* {" "\tfont-family: ${fuente};" "}" "" ]
			++ map builtins.readFile hojas
		);

		settings = {
			mainbar = {
				layer = "top";
				position = "top";
				spacing = 15;
				height = 30;
				reload_style_on_change = true;
				fixed-center = true;

				modules-left = [
					"hyprland/workspaces"
					"hyprland/window"
				];

				modules-center = [
					"clock"
				];

				modules-right = [
					"disk"
					"memory"
					"cpu"
					"temperature"
					"battery"
					"tray"
				    "custom/notifications"
				];

				"hyprland/workspaces" = {
					active-only = false;
					all-outputs = false;
					format = "{icon}";
					format-icons = numeros;
				};

				"hyprland/window" = {
					separate-outputs = true;
					icon = true;
					icon-size = 20;
					max-length = 50;
				};

				clock = {
					timezone = "America/Argentina/Buenos_Aires";
					format = "{:%d/%m  %H:%M}";
					format-alt = "{:%A %d, %B  %H:%M:%S}";
					actions = {
						on-click = "mode";
					};
				};

				tray = {
					icon-size = 20;
					spacing = 10;
				};

				temperature = {
					# NOTE: this is is platform dependent
					thermal-zone = 6;
					format = "<span font='Noto Color Emoji'>🌡</span>{temperatureC}°C";
					critical-threshold = 80;
				};

				cpu = {
					interval = 2;
					format = "<span font='Noto Color Emoji'>🪨</span>{usage}%";
					states = {
						critical = 95;
					};
				};

				memory = {
					interval = 2;
					format = "<span font='Noto Color Emoji'>💾</span>{percentage}%";
					states = {
						critical = 90;
					};
				};

				disk = {
					interval = 20;
					format = "<span font='Noto Color Emoji'>📂</span>{percentage_used}%";
					states = {
						warning = 80;
						critical = 95;
					};
				};

				battery = {
					interval = 20;
					states = {
						warning = 30;
						critical = 15;
					};

					format = "<span font='Noto Color Emoji'>{icon}</span> {capacity}%";
					format-icons = {
						charging = "🔌";
						discharging = "🔋";
						full = "🔋";
						plugged = "🔋";
					};
				};

				"custom/notifications" = {
					tooltip = false;
					format = "<span font='Noto Color Emoji'>{icon}</span> {text}";
					format-icons = {
						notification = "🔔<sup>❕</sup>";
						none = "🔔";
						dnd-notification = "🔕<sup>❕</sup>";
						dnd-none = "🔕";
						inhibited-notification = "🔕<sup>❕</sup>";
						inhibited-none = "🔕";
						dnd-inhibited-notification = "🔕<sup>❕</sup>";
						dnd-inhibited-none = "🔕";
					};

					return-type = "json";
					exec-if = "which swaync-client";
					exec = "swaync-client -swb";
					on-click = "swaync-client -t -sw";
					on-click-right = "swaync-client -d -sw";
					escape = true;
				};
			} // lib.optionalAttrs tema.enable islas;
		};
	};
}
