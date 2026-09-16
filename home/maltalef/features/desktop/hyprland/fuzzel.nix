{ ... }: {
	# launcher: fuzzel en vez de wofi (mismo programa que el backend del menú
	# de tessen, pero con su config default ~/.config/fuzzel; la de tessen va
	# aparte vía fuzzel_config_file). Colores calcados de cómo se veía wofi:
	# sin style.css propio tomaba los del tema GTK (Gruvbox-Dark), o sea
	# fondo 1d2021, texto fbf1c7, selección 7daea3 con texto oscuro y borde
	# fbf1c7 al 12%. La font es la de foot.nix (wofi usaba la default de
	# GTK).
	programs.fuzzel = {
		enable = true;

		settings = {
			main = {
				font = "FiraCode Nerd Font:pixelsize=13";
				# para .desktop con Terminal=true; los íconos como en el drun
				# de wofi, que salían del tema de gtk.iconTheme
				terminal = "footclient";
				icon-theme = "Papirus-Dark";
				lines = 12;
				width = 45;
				horizontal-pad = 14;
				vertical-pad = 10;
			};

			colors = {
				background = "1d2021ff";
				text = "fbf1c7ff";
				match = "d8a657ff";
				selection = "7daea3ff";
				selection-text = "1d2021ff";
				# igual a selection-text: wofi tampoco resaltaba el match en la
				# fila seleccionada
				selection-match = "1d2021ff";
				border = "fbf1c71f";
			};

			border = {
				width = 1;
				radius = 8;
			};
		};
	};
}
