{ pkgs, lib, config, ... }: {
  programs.git = {
    enable = true;
    userName = "mw";
    userEmail = "mw@exumpul.com";
    extraConfig = { 
	  init.defaultBranch = "main"; 
	  safe.directory = "*";
	};
  };
}
