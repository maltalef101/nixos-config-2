{ pkgs, ... }: {
  programs.nushell = {
    enable = true;
    shellAliases = rec {
      ls = "^eza --group-directories-first";
      ll = "^eza --group-directories-first -al";
      la = "^eza --group-directories-first -a";
      vim = "^nvim";
      v = "^nvim";
      dv = "cd ~/dev";
    };
	
    configFile.source = ./config/config.nu;
    envFile.source = ./config/env.nu;
    loginFile.source = ./config/login.nu;
  };
}
