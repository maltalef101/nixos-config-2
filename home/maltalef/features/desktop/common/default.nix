{ pkgs, ... }: {
  imports = [
	#./birdtray.nix
	#./unclutter.nix
	./zathura.nix
    ./alacritty
    #./dragon.nix
    ./dunst.nix
    ./firefox.nix
    ./font.nix
    # ./redshift.nix
    # ./rofi.nix
    ./xdg.nix
  ];

  home.packages = with pkgs; [ 
    xclip
	pulsemixer
	# NOTE: why is this here?
	python3 
	# NOTE: why is this here?
	gcc
	maim
	mpv
	# TODO: write standalone config for thunderbird
	thunderbird

	# personal helper scripts
	hyprshot-full
	hyprshot-region
  ];
}
