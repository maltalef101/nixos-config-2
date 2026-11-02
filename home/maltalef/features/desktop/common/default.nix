{ pkgs, ... }: {
  imports = [
	#./birdtray.nix
	#./unclutter.nix
	./zathura.nix
    ./foot.nix
    #./dragon.nix
    ./firefox.nix
    ./font.nix
    ./mimeapps.nix
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
	nautilus
	nautilus-open-any-terminal
	nsxiv

	# personal helper scripts
	hyprshot-full
	hyprshot-region
	# vista previa de markdown (WebKit, estilo GitHub oscuro) con recarga al guardar
	mdview
  ];
}
