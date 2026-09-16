{ pkgs, config, ... }: {
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

		# gruvbox desde la paleta salvo dos hardcodes: el acento es el mismo
		# verde 689d6a del borde activo de hyprland y el dimmed es el gris
		# 928374 (comment de gruvbox); ninguno de los dos es color base16
		# (base03 de fondo dimmed era ilegible)
		theme = with config.colorScheme.palette; {
			useCustom = true;

			TitleFore = "#${base00}";
			TitleBack = "#689d6a";
			TitleInfo = "#${base04}";

			NormalTitle = "#${base07}";
			NormalDesc = "#${base03}";
			DimmedTitle = "#928374";
			DimmedDesc = "#${base02}";

			# cursor: verde con barra clara a la izquierda; marcados con `s`:
			# amarillo (los campos Marked* existen por el parche)
			SelectedTitle = "#689d6a";
			SelectedDesc = "#689d6a";
			SelectedDescBorder = "#${base07}";
			SelectedBorder = "#689d6a"; # muerto en 1.2.1, por si upstream lo usa
			MarkedTitle = "#${base0A}";
			MarkedDesc = "#${base0A}";

			FilteredMatch = "#${base0A}";
			FilterPrompt = "#${base0C}";
			FilterInfo = "#689d6a";
			FilterText = "#${base07}";
			FilterCursor = "#${base09}";

			StatusMsg = "#${base0B}";
			PinIndicatorColor = "#${base0A}";
			HelpKey = "#${base04}";
			HelpDesc = "#${base03}";
			PageActiveDot = "#689d6a";
			PageInactiveDot = "#${base02}";
			DividerDot = "#${base03}";
			PreviewedText = "#${base07}";
			PreviewBorder = "#689d6a";
		};
	};
}
