{ pkgs, lib, config, ...}: 
{
  programs.ssh = {
    enable = true;
  };
}
