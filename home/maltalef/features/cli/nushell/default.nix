{ pkgs, ... }: {
  programs.nushell = {
    enable = true;
    shellAliases = rec {
      ls = "^exa --group-directories-first";
      ll = "^exa --group-directories-first -al";
      la = "^exa --group-directories-first -a";
      vim = "^nvim";
      v = "^nvim";
      dv = "cd ~/dev";
    };
	
    configFile.source = ./config/config.nu;
    envFile.source = ./config/env.nu;
    loginFile.source = ./config/login.nu;
  };
}
