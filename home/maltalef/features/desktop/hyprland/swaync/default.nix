{ pkgs, ...}: {
	services.swaync = {
		enable = true;


 		settings = {
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
