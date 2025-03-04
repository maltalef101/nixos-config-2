{ pkgs, inputs, ... }: {
	imports = [ ../common ./waybar ./wofi ./hyprlock.nix ./hypridle.nix ./swaync ];

	home.pointerCursor = {
		package = pkgs.capitaine-cursors;
		name = "capitaine-cursors";
		size = 24;
	};

	gtk = {
		enable = true;

		theme = {
			package = pkgs.gruvbox-gtk-theme;
			name = "Gruvbox-Dark";
		};

		iconTheme = {
			package = pkgs.papirus-icon-theme;
			name = "Papirus-Dark";
		};
	};

	wayland.windowManager.hyprland = {
		enable = true;
		xwayland.enable = true;

		settings = {
			"$mod" = "SUPER";
			"$terminal" = "alacritty";

#			env = [
#				"HYPRCURSOR_THEME,capitaine-cursors"
#				"HYPRCURSOR_SIZE,24"
#			];

			exec-once = "swaync & waybar & blueman-applet & nm-applet";

			exec = [
				"thunderbird"
			];

			general = {
				gaps_in = 8;
				gaps_out = 7;
				border_size = 5;

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
			};

			input = {
				kb_layout = "es";
				kb_options = "caps:swapescape";

				repeat_rate = 30;
				repeat_delay = 160;

				follow_mouse = "2";
			};

			cursor = {
				no_warps = true;
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

			workspace = [
				"special:volume, on-created-empty:[float; size 950 400; move 20 50] alacritty -e pulsemixer"
				"special:chat, on-created-empty:telegram-desktop"
				"special:scratchpad, on-created-empty:[float; size 700 400; center] alacritty"
			];

			windowrulev2 = [
				"workspacesilent special:mail, class:(thunderbird)"
			];

			bindm = [
				"$mod, mouse:272, movewindow"
				"$mod, mouse:273, resizewindow"
			];

			bindel = [
				", XF86MonBrightnessUp, exec, brightnessctl s 5%+"
				", XF86MonBrightnessDown, exec, brightnessctl s 5%-"
				
			];

			bind = [
				"$mod, Return, exec, $terminal"
				"$mod, space, togglefloating"
				"$mod, q, killactive"
				"$mod, Tab, workspace, previous"
				"$mod, f, fullscreen"

				"$mod, j, cyclenext, prev"
				"$mod, k, cyclenext"
				"$mod SHIFT, k, layoutmsg, swapprev"
				"$mod SHIFT, j, layoutmsg, swapnext"
				"$mod SHIFT, Return, layoutmsg, swapwithmaster"
				"$mod SHIFT, code:60, layoutmsg, addmaster"
				"$mod SHIFT, code:59, layoutmsg, removemaster"
				"$mod, l, focusmonitor, +1"
				"$mod, h, focusmonitor, -1"
				"$mod SHIFT, l, movewindow, mon:+1"
				"$mod SHIFT, h, movewindow, mon:-1"

				"$mod, d, exec, wofi -S run"
				"$mod SHIFT, d, exec, wofi -S drun"

				"$mod Control_L, x, exec, hyprlock"

				"Alt_L, Space, exec, swaync-client --close-latest"
				"Alt_L SHIFT, Space, exec, swaync-client -C"
				
				", Print, exec, hyprshot-region"
				"SHIFT, Print, exec, hyprshot-full"

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
						"$mod, code:1${toString i}, focusworkspaceoncurrentmonitor, ${toString ws}"
						"$mod SHIFT, code:1${toString i}, movetoworkspacesilent, ${toString ws}"
					]
				)
				10)
			);
		};
	};
}
