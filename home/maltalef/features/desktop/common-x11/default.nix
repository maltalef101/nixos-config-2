{ pkgs, ... }: {
  imports = [
	./unclutter.nix
    ./alacritty
    ./dragon.nix
    ./dunst.nix
    ./firefox.nix
    ./font.nix
    ./redshift.nix
    ./rofi.nix
    ./xdg.nix
	./zathura.nix
  ];

  home.packages = with pkgs; [ 
    xclip
	pulsemixer
	python3
	gcc
	maim
	mpv

	# personal helper scripts
	maimsel
	maimfull
  ];
}
