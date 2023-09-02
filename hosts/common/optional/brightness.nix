{ pkgs, lib, ... }:
{
  environment.systemPackages = [ pkgs.brightnessctl ];
}
