{ pkgs, config, lib, ... }: {
  imports = [ 
	./git.nix 
	./ssh.nix 
	./zsh 
	./nvim 
	./tmux.nix 
	./starship.nix 
	./gpg.nix 
	./superfile.nix
  ];

  home.packages = with pkgs; [
    bc # Calclator
	btop
    ncdu # Nicer disk usage
    eza # Better ls
    ripgrep # Better (and faster) grep
    fd # Better find
    httpie # Better curl
    nixfmt # For formatting nix files
	bandwhich # Bandwidth utilization tool
	bluetuith # bluetooth connection manager (could be configured, but default is fine)
	whois
	file
	wget
	unzip
	dosfstools
	usbutils
	pv
  ];

  programs.bash.enable = true;
}
