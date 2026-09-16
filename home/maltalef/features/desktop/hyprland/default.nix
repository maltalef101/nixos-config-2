{ pkgs, inputs, config, ... }: {
	imports = [
		../common
		./waybar
		./fuzzel.nix
		./hyprlock.nix
		./hypridle.nix
		./hyprsunset.nix
		./hyprpaper.nix
		./swaync
		./tessen.nix
		./clipse.nix
	];

	# Wrapper de lock: guard por usuario + LockedHint de logind (hyprlock no
	# setea el hint, hyprwm/hyprlock#907). Es quien ejecuta hyprlock tanto en
	# el keybind como en hypridle, así que va en el profile. El override hace
	# que envuelva el mismo hyprlock que programs.hyprlock (el del flake), no
	# el de nixpkgs.
	home.packages = [
		(pkgs.hyprlock-lock.override { hyprlock = config.programs.hyprlock.package; })
		pkgs.hypr-merge-rogues
		pkgs.hypr-cycle-monitor
	];

	home.pointerCursor = {
		package = pkgs.capitaine-cursors;
		name = "capitaine-cursors";
		size = 24;
	};

	gtk = {
		enable = true;
    gtk4.theme = config.gtk.theme;

		theme = {
			package = pkgs.gruvbox-gtk-theme;
			name = "Gruvbox-Dark";
		};

		iconTheme = {
			package = pkgs.papirus-icon-theme;
			name = "Papirus-Dark";
		};
	};

	# el portal Settings (impl gtk) lee color-scheme de dconf; sin esto las apps
	# portal-aware (Signal/Electron 43+) ven "no preference" y caen a light mode
	dconf.settings."org/gnome/desktop/interface".color-scheme = "prefer-dark";

	wayland.windowManager.hyprland = {
		enable = true;
		xwayland.enable = true;

		# Workspaces por monitor, estilo dwm: cada monitor tiene sus propios
		# tags 1-10 (internamente 1-10, 11-20, ...). Vía keyword plugin= y no
		# plugins=[] de hm (exec-once): hyprland carga el .so post-parse y
		# re-parsea solo, así los binds split-* no dan "invalid dispatcher"
		# al arrancar.
		extraConfig = "plugin = ${inputs.split-monitor-workspaces.packages.${pkgs.system}.split-monitor-workspaces}/lib/libsplit-monitor-workspaces.so";

    # HACER: migrar config a lua? hyprland cambió su formato en la última
    # release a la fecha (13062026) y na ta bueno qsy
    configType = "hyprlang";

		settings = {
			plugin = {
				"split-monitor-workspaces".count = 10;

				touch_gestures = {
					workspace_swipe_fingers = 3;
					workspace_swipe_edge = "d";
					long_press_delay = 400;
					resize_on_border_long_press = true;
					edge_margin = 30;

					hyprgrass-bind = [
						", swipe:3:u, exec, notify-send ahaha"
					];
				};
			};

			"$mod" = "SUPER";
			"$terminal" = "footclient";

#			env = [
#				"HYPRCURSOR_THEME,capitaine-cursors"
#				"HYPRCURSOR_SIZE,24"
#			];

			# hyprpaper lo gestiona services.hyprpaper (systemd user unit); no
			# lanzarlo acá también o se duplica y crashea (conflicto de socket).
			exec-once = [
				"waybar & blueman-applet & nm-applet"
				"hypr-merge-rogues"
			];

			general = {
				gaps_in = 8;
				gaps_out = 7;
				border_size = 5;

				resize_on_border = true;

				layout = "master";
				
				"col.active_border" = "rgb(689d6a)";
				"col.inactive_border" = "rgb(1d2021)";
			};

			debug.disable_logs = false;

			misc = {
				force_default_wallpaper = 0;
				disable_hyprland_logo = true;
				disable_splash_rendering = true;

				## i'd like this to not be enabled, but when spawning empty special
				## workspaces that have a rule to execute something in them, it doesn't get
				## focused on spawn

				initial_workspace_tracking = 0;

				# swallow scopeado por app-id: solo la terminal del file browser
				# ($mod+e / xdg-open en directorios) se traga al abrir una app
				# gráfica; los foot comunes (clase "foot") no matchean
				enable_swallow = true;
				swallow_regex = "^(superfile)$";
			};

			input = {
				kb_layout = "us";
				kb_variant = "altgr-intl";
				kb_options = "caps:swapescape";

				repeat_rate = 30;
				repeat_delay = 160;

				follow_mouse = "2";
				touchdevice.output = "eDP-1";
			};

			cursor = {
				# warps habilitados (default): con no_warps, vaciar un workspace vía
				# movetoworkspacesilent dispara refocus() y el foco salta al monitor
				# donde quedó el cursor (hyprwm/Hyprland#13770)
				persistent_warps = true;
				inactive_timeout = 2;
				enable_hyprcursor = false; # capitaine-cursors doesn't have hyprcursor support obviously
			};

			master = {
				## FIXME(maltalef): only present in v0.42 and up
				new_status = "master";
				new_on_top = true;

				mfact = 0.5;
			};

			binds = {
				allow_workspace_cycles = true;
			};

			animation = [
				"workspaces,1,2,default"
				"specialWorkspace,1,2,default,slidevert"
				"windows,1,2,default,slide"
				"border,1,2,default"
				"fade,1,2,default"
				"layers,1,2,default"
			];

			decoration = {
				rounding = 2;
			};

			# geometría vía windowrule por app-id y no exec rules inline: hyprland
			# aplica las exec rules por PID del proceso lanzado, y con footclient
			# la ventana la crea el server (otro PID), así que nunca matchean
			workspace = [
				"special:volume, on-created-empty:footclient --app-id=foot-volume pulsemixer"
				"special:chat, on-created-empty:telegram-desktop"
				"special:scratchpad, on-created-empty:footclient --app-id=foot-scratchpad"
			];

			# sintaxis nueva (0.56): campos "clave valor" separados por coma,
			# matchers con prefijo match: y efectos booleanos con valor explícito
			windowrule = [
				"float on, size 950 400, move 20 50, match:class ^(foot-volume)$"
				"float on, size 700 400, center on, match:class ^(foot-scratchpad)$"
				"float on, size 800 800, center on, match:class ^(clipse)$"
			];

			bindm = [
				"$mod, mouse:272, movewindow"
				"$mod, mouse:273, resizewindow"
			];

			bindel = [
				", XF86MonBrightnessUp, exec, brightnessctl s 4%+"
				", XF86MonBrightnessDown, exec, brightnessctl s 4%-"
				", XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
				", XF86AudioMicMute, exec, wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"
				", XF86AudioRaiseVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 4%+"
				", XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 4%-"
				", XF86NotificationCenter, exec, swaync-client -tsw"
			];

			bind = [
				"$mod, Return, exec, $terminal"
				"$mod, space, togglefloating"
				"$mod, q, killactive"
				"$mod, Tab, workspace, previous_per_monitor"
				"$mod, f, fullscreen"

				"$mod, j, layoutmsg, cyclenext"
				"$mod, k, layoutmsg, cycleprev"
				"$mod SHIFT, k, layoutmsg, swapprev"
				"$mod SHIFT, j, layoutmsg, swapnext"
				"$mod SHIFT, Return, layoutmsg, swapwithmaster"
				"$mod SHIFT, code:60, layoutmsg, addmaster"
				"$mod SHIFT, code:59, layoutmsg, removemaster"
				# anillo espacial (por columnas), no el +1/-1 por orden de
				# creación: h/l siguen la disposición física de los monitores
				"$mod, l, exec, hypr-cycle-monitor next"
				"$mod, h, exec, hypr-cycle-monitor prev"
				"$mod SHIFT, l, exec, hypr-cycle-monitor --move next"
				"$mod SHIFT, h, exec, hypr-cycle-monitor --move prev"
				# junta ventanas varadas en workspaces fuera del rango del
				# monitor (p. ej. tras desconectar uno)
				"$mod SHIFT, g, split-grabroguewindows"

				# launcher (fuzzel.nix): apps + binarios del PATH; con shift,
				# solo apps (el drun de antes)
				"$mod, d, exec, fuzzel --list-executables-in-path"
				"$mod SHIFT, d, exec, fuzzel"

				# file browser en ~; foot standalone y no $terminal (footclient):
				# el swallow necesita que la ventana tenga PID propio
				"$mod, e, exec, foot --app-id=superfile -D ~ superfile"

				# menú de pass (tessen.nix): Enter copia el password, Ctrl+o el
				# OTP, Ctrl+Enter abre el menú de campos
				"$mod, p, exec, tessen"

				# historial del clipboard (clipse.nix): Enter copia, space
				# previsualiza (sixel), s marca, / filtra, p pinnea
				"$mod, c, exec, footclient --app-id=clipse clipse"

				"$mod Control_L, x, exec, hyprlock-lock"

				"Alt_L, Space, exec, swaync-client --close-latest"
				"Alt_L SHIFT, Space, exec, swaync-client -C"
				
				", Print, exec, hyprshot-region"
				"SHIFT, Print, exec, hyprshot-full"

				", XF86SelectiveScreenshot, exec, hyprshot-region"
				"SHIFT, XF86SelectiveScreenshot, exec, hyprshot-full"

				"$mod, v, togglespecialworkspace, volume"
				"$mod, g, togglespecialworkspace, scratchpad"
				"$mod, m, togglespecialworkspace, mail"
				"$mod, y, togglespecialworkspace, chat"

			]
			++ (
				# Workspaces
				builtins.concatLists (builtins.genList (i:
					let ws = i + 1;
					in [
						"$mod, code:1${toString i}, split-workspace, ${toString ws}"
						"$mod SHIFT, code:1${toString i}, split-movetoworkspacesilent, ${toString ws}"
					]
				)
				10)
			);
		};
	};

	services.mpris-proxy.enable  = true; 
}
