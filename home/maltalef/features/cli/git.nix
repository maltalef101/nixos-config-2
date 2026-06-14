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
	  };
  };
}
