{ pkgs, ... }: {
  imports =
    [ ./startx ./dragon.nix ./dunst.nix ./font.nix ./redshift.nix ./rofi.nix ./xdg.nix ./alacritty ];

  home.packages = with pkgs; [
	xclip
  ];
}
