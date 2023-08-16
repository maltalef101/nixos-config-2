{ pkgs, ... }: {
  programs.nushell = {
    enable = true;
    shellAliases = {
      ls = "^exa";
      ll = "ls -al";
      la = "ls -a";
      vim = "^nvim";
      v = "vim";
      dv = "cd ~/dev";
    };
  };
}
