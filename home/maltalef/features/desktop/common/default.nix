{ pkgs, ... }: {
  imports = [
	./maim.nix
	./unclutter.nix
    ./alacritty
    ./dragon.nix
    ./dunst.nix
    ./firefox.nix
    ./font.nix
    ./network.nix
    ./redshift.nix
    ./rofi.nix
    ./startx
    ./xdg.nix
  ];

  home.packages = with pkgs; [ 
    xclip
	pulsemixer
	python3
	gcc
  ];
}
