{ pkgs, inputs, config, lib, ...}:
let
	tema = config.tema;

	# Con el tema (pirincho): el fondo del tema (fondo.imagen) desenfocado
	# y oscurecido, el campo en los colores de la paleta (campo, texto, borde
	# en el acento, el foco al chequear, el rojo de error al fallar) en la
	# fuente de interfaz, y la hora grande en el texto claro con la fecha
	# debajo en el tenue, en la de cifras (tema.fuentes.cifras). Si no, lo de
	# siempre.
	colores = if tema.enable then with tema.colores; {
		fondo = "rgb(${fondo})";
		borde = "rgb(${acento})";
		campo = "rgb(${campo})";
		textoCampo = "rgb(${texto})";
		chequeando = "rgb(${foco})";
		# el texto de la falla se pinta con fail_color (su primer color), que
		# es también el borde: el rojo claro, que sobre el campo se lee
		falla = "rgb(${error})";
		hora = "rgb(${textoClaro})";
		fecha = "rgb(${textoTenue})";
		sombra = "rgba(${fondoHondo}cc)";
	} else {
		fondo = "rgba(25, 20, 20, 1.0)";
		borde = "rgb(151515)";
		campo = "rgb(200, 200, 200)";
		textoCampo = "rgb(10, 10, 10)";
		chequeando = "rgb(204, 136, 34)";
		falla = "rgb(204, 34, 34)";
		hora = "rgba(200, 200, 200, 1.0)";
	};
in {
	programs.hyprlock = {
		enable = true;
		package = inputs.hyprlock.packages.${pkgs.stdenv.hostPlatform.system}.hyprlock;

		settings = {
			general = {
				ignore_empty_input = false;
			};

			# Huella vía fprintd (D-Bus), en paralelo a la contraseña por PAM.
			# En hosts sin lector no hace nada.
			auth = {
				fingerprint.enabled = true;
			};

			# Con el tema, sus animaciones (las curvas de
			# animaciones.nix): el bloqueo aparece en 300 ms sobre el escritorio
			# y se va en 200 al desbloquear; el campo cambia de color al chequear
			# y al fallar, se ensancha con el texto de la falla y se desvanece
			# vacío, todo en 200-300 ms. Sin el tema, las de hyprlock (800 ms
			# para todo). La velocidad va en décimas de segundo y hyprlock la
			# trunca a un entero.
			animations = lib.mkIf tema.enable {
				enabled = true;
				bezier = [
					"suave, 0.22, 1, 0.36, 1"
					"salida, 0.3, 0, 1, 1"
				];
				animation = [
					"fadeIn, 1, 3, suave"
					"fadeOut, 1, 2, salida"
					"inputFieldColors, 1, 2, suave"
					"inputFieldWidth, 1, 2, suave"
					"inputFieldFade, 1, 3, suave"
					"inputFieldDots, 1, 1, suave"
				];
			};

			background = {
				monitor = "";
				color = colores.fondo;
			} // lib.optionalAttrs tema.enable {
				path = "${tema.fondo.imagen}";
				# Que el fondo quede como una textura oscura, sin detalle que
				# compita con la hora (las hojas del de gruvbox-verde tienen
				# mucho): tres pasadas de blur y menos brillo.
				blur_passes = 3;
				blur_size = 10;
				brightness = 0.65;
				contrast = 0.9;
				vibrancy = 0.15;
			};

			input-field = {
				monitor = "";
				size = "200, 50";
				outline_thickness = 3;
				dots_size = 0.33;
				dots_spacing = 0.15;
				dots_center = false;
				dots_rounding = -1;
				#dots_fade_time = 200;
				#dots_text_format = "";
				outer_color = colores.borde;
				inner_color = colores.campo;
				font_color = colores.textoCampo;
				#font_family = "Noto Sans";
				fade_on_empty = true;
				fade_timeout = 1000;
				placeholder_text = "<i>Password...</i>";
				hide_input = false;
				rounding = -1;
				check_color = colores.chequeando;
				fail_color = colores.falla;
				fail_text = "<i>$FAIL <b>($ATTEMPTS)</b></i>";
				#fail_timeout = 2000;
				capslock_color = -1;
				numlock_color = -1;
				bothlock_color = -1;
				invert_numlock = false;
				swap_font_color = false;

				position = "0, -20";
				halign = "center";
				valign = "center";
			} // lib.optionalAttrs tema.enable {
				font_family = tema.fuentes.interfaz;
			};

			# Con el tema, la hora grande con una sombra que la despega del fondo,
			# y la fecha debajo (en el LC_TIME de la sesión).
			label = if tema.enable then [
				{
					monitor = "";
					text = "cmd[update:1000] date '+%H:%M'";
					text_align = "center";
					color = colores.hora;
					font_size = 72;
					font_family = tema.fuentes.cifras;
					shadow_passes = 2;
					shadow_size = 4;
					shadow_color = colores.sombra;

					position = "0, 170";
					halign = "center";
					valign = "center";
				}
				{
					monitor = "";
					text = "cmd[update:60000] date '+%A %-d de %B'";
					text_align = "center";
					color = colores.fecha;
					font_size = 16;
					font_family = tema.fuentes.cifras;
					shadow_passes = 2;
					shadow_size = 3;
					shadow_color = colores.sombra;

					position = "0, 85";
					halign = "center";
					valign = "center";
				}
			] else {
				monitor = "";
				text = "cmd[update:1000] date '+%H:%M'";
				text_align = "center";
				color = colores.hora;
				font_size = 25;
				font_family = "Noto Sans";
				rotate = 0;

				position = "0, 80";
				halign = "center";
				valign = "center";
			};
		};
	};
}
