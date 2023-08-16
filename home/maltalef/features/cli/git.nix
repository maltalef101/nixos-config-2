{ pkgs, lib, config, ... }: {
  programs.git = {
    enable = true;
    userName = "Manuel Altalef";
    userEmail = "maltalef@auror.ar";
    extraConfig = { init.defaultBranch = "main"; };
  };
}
