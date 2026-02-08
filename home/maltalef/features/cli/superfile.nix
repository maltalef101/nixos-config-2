{ pkgs, lib, ... }: {
  programs.superfile = {
    enable = true;
	settings = {
		theme = "gruvbox-dark-hard";
	};
  };
}
