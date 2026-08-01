{ pkgs, lib, config, ... }: {
  programs.git = {
    enable = true;
    settings = {
      user.name = "Manuel Altalef";
      user.email = "maltalef@auror.ar";
	    init.defaultBranch = "main";
	    safe.directory = "*";
    };

	  signing = {
		  format = "openpgp";
		  signByDefault = true;
		  key = "0x96AB62E9F32E5934!"; # subclave [S]; el ! fuerza esa subclave exacta
	  };
  };
}
