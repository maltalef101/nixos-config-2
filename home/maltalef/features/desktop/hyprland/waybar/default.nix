{ pkgs, ... }: {
	programs.waybar = {
		enable = true;

		style = ./style.css;

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
					format_icons = {
						charging = "🔌";
						discharging = "🔋";
						full = "🔋";
					};
				};
				
				"custom/notifications" = {
					tooltip = false;
					format = "<span font='Noto Color Emoji'>{icon}</span> {}";
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
		};
	};
}
