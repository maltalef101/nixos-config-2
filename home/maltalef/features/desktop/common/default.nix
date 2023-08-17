{ pkgs, ... }: {
  imports = [
    ./startx
    ./network.nix
    ./dragon.nix
    ./firefox.nix
    ./dunst.nix
    ./font.nix
    ./redshift.nix
    ./rofi.nix
    ./xdg.nix
    ./alacritty
  ];

  home.packages = with pkgs; [ 
    xclip
	pulsemixer
	python3
	gcc
  ];
}
