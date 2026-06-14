{ pkgs, lib, config, ... }: {
  programs.git = {
    enable = true;
    settings = {
      user.name = "mw";
      user.email = "mw@exumpl";
	    init.defaultBranch = "main";
	    safe.directory = "*";
    };
  };
}
