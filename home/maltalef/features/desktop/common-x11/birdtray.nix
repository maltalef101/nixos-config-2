{ pkgs, lib, inputs, ... }: {
	home.packages = with pkgs; [ birdtray ];

	systemd.user.services = {
		birdtray = {
			Install = {
				WantedBy = "graphical-session.target";
			};

			Service = {
				ExecStart = "${pkgs.birdtray}/bin/birdtray";
				Restart = "on-failure";
				RestartSec = 3;
			};

			Unit = {
				After = "graphical-session-pre.target";
				Description = "Free system tray notification for new mail for Thunderbird.";
				Documentation = "https://github.com/gyunaev/birdtray";
				PartOf = "graphical-session.target";
			};
		};
	};
}
