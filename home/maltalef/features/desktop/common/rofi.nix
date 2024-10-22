{ pkgs, ... }: {
  programs.rofi = {
    enable = true;
    theme = "gruvbox-dark-hard.rasi";
	terminal = "${pkgs.alacritty}/bin/alacritty";

	extraConfig = {
		show-icons = true;
		sidebar-mode = true;
	};
  };
}
