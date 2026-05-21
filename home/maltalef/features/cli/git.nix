{ pkgs, lib, config, ... }: {
  programs.git = {
    enable = true;
    userName = "Manuel Altalef";
    userEmail = "maltalef@auror.ar";
	signing = {
		format = "openpgp";
		signByDefault = true;
	};
    extraConfig = { 
	  init.defaultBranch = "main"; 
	  safe.directory = "*";
	};
  };
}
