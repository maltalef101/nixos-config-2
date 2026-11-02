{ pkgs, config, ... }:
let
	tema = config.tema;
in {
	# clipboard manager: listener que ve cada selección nueva vía wl-paste
	# --watch (protocolo wlr-data-control) y persiste el historial en
	# ~/.config/clipse/clipboard_history.json (texto plano, ojo). El TUI se
	# abre flotante con $mod+c (bind y windowrule en default.nix). tessen
	# pausa el listener mientras copia secretos (ver tessen.nix).
	services.clipse = {
		enable = true;

		# parche propio: color aparte para los ítems marcados con `s`
		# (MarkedTitle/MarkedDesc, campos nuevos del theme) y resaltado por
		# caracter de los matches del filtro vía FilteredMatch, que upstream
		# define en el theme pero nunca usa (v1.2.1; sigue muerto en main)
		package = pkgs.clipse.overrideAttrs (old: {
			patches = (old.patches or [ ]) ++ [ ./clipse-marked-and-match-colors.patch ];
		});

		# clipse mergea este json sobre sus defaults, alcanza con declarar
		# las desviaciones
		settings = {
			# foot habla sixel, no kitty graphics; con "basic" (default) la
			# imagen no se ve, solo un placeholder. El preview de imágenes
			# grandes bloquea el TUI unos segundos (decode+encode sincrónico).
			imageDisplay.type = "sixel";

			keyBindings = {
				up = "k";
				down = "j";
				nextPage = "l";
				prevPage = "h";
			};
		};

		# desde la paleta (colorScheme) salvo los colores de `c`, que no son
		# base16. Con el tema: el título en el acento de la paleta, el resto
		# del acento en el foco (un acento oscuro no se lee como texto sobre
		# el fondo; en gruvbox-verde, 8ec07c) y el dimmed en el apagado de la
		# paleta (en gruvbox-verde el gris 928374, porque su base03 es
		# ilegible). Si no, gruvbox: el
		# acento es el mismo verde 689d6a del borde activo de hyprland y el
		# dimmed es el gris 928374
		theme = with config.colorScheme.palette; let
			c = if tema.enable then {
				tituloTexto = tema.colores.sobreAcento;
				tituloFondo = tema.colores.acento;
				acento = tema.colores.foco;
				apagado = tema.colores.apagado;
			} else {
				tituloTexto = base00;
				tituloFondo = "689d6a";
				acento = "689d6a";
				apagado = "928374";
			};
		in {
			useCustom = true;

			TitleFore = "#${c.tituloTexto}";
			TitleBack = "#${c.tituloFondo}";
			TitleInfo = "#${base04}";

			NormalTitle = "#${base07}";
			NormalDesc = "#${base03}";
			DimmedTitle = "#${c.apagado}";
			DimmedDesc = "#${base02}";

			# cursor: verde con barra clara a la izquierda; marcados con `s`:
			# amarillo (los campos Marked* existen por el parche)
			SelectedTitle = "#${c.acento}";
			SelectedDesc = "#${c.acento}";
			SelectedDescBorder = "#${base07}";
			SelectedBorder = "#${c.acento}"; # muerto en 1.2.1, por si upstream lo usa
			MarkedTitle = "#${base0A}";
			MarkedDesc = "#${base0A}";

			FilteredMatch = "#${base0A}";
			FilterPrompt = "#${base0C}";
			FilterInfo = "#${c.acento}";
			FilterText = "#${base07}";
			FilterCursor = "#${base09}";

			StatusMsg = "#${base0B}";
			PinIndicatorColor = "#${base0A}";
			HelpKey = "#${base04}";
			HelpDesc = "#${base03}";
			PageActiveDot = "#${c.acento}";
			PageInactiveDot = "#${base02}";
			DividerDot = "#${base03}";
			PreviewedText = "#${base07}";
			PreviewBorder = "#${c.acento}";
		};
	};
}
