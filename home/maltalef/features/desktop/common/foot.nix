{ ... }: {
	programs.foot = {
		enable = true;

		# foot --server como unit de systemd (user); las ventanas se abren con
		# footclient, casi instantáneo. Si el server muere se llevan todas las
		# ventanas, pero tmux amortigua
		server.enable = true;

		settings = {
			main = {
				# px enteros para que el hinting no salte con el zoom (13px ≈ los
				# 9.5pt de alacritty). Compromiso asumido: el line-height fijo
				# escala con redondeo y el interlineado baila ±1px fuera del
				# tamaño base
				font = "FiraCode Nerd Font:pixelsize=13";
				# natural de firacode (16px a 13px de em) + 2px, como el
				# font.offset.y = 2 que traía alacritty
				line-height = "18px";
				font-size-adjustment = "1px";
				pad = "7x7";
			};

			# en RAM y por ventana: se llena de a poco, pero lleno puede pesar GBs
			scrollback.lines = 1000000;

			cursor = {
				style = "block";
				blink = "yes";
			};

			# gruvbox dark (medium), portado literal de alacritty.toml; no sale de
			# nix-colors porque el scheme global es -hard (fondo 1d2021, no 282828)
			"colors-dark" = {
				background = "282828";
				foreground = "ebdbb2";

				regular0 = "282828";
				regular1 = "cc241d";
				regular2 = "98971a";
				regular3 = "d79921";
				regular4 = "458588";
				regular5 = "b16286";
				regular6 = "689d6a";
				regular7 = "ebdbb2";

				bright0 = "928374";
				bright1 = "fb4934";
				bright2 = "b8bb26";
				bright3 = "fabd2f";
				bright4 = "83a598";
				bright5 = "d3869b";
				bright6 = "8ec07c";
				bright7 = "fbf1c7";
			};

			# asignar un binding pisa el default, así que los de copy/paste llevan
			# también el Ctrl+Shift de siempre
			key-bindings = {
				scrollback-up-line = "Mod1+k";
				scrollback-down-line = "Mod1+j";
				scrollback-up-page = "Mod1+u";
				scrollback-down-page = "Mod1+d";
				clipboard-copy = "Control+Shift+c Mod1+c";
				clipboard-paste = "Control+Shift+v Mod1+v";
			};
		};
	};

	# terminal que abre nautilus-open-any-terminal; sin la key usa su default
	# (gnome-terminal), que no está instalado
	dconf.settings."com/github/stunkymonkey/nautilus-open-any-terminal".terminal = "foot";
}
