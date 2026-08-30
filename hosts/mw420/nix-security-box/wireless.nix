# Wireless tools

{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    aircrack-ng
    airgeddon
    bully
    cowpatty
    dbmonster
    hcxdumptool
    hcxtools
    horst
    killerbee
    kismet
    netscanner
    pixiewps
    reaverwps
    wavemon
    wifite2
    # zigpy-cli # build roto en nixpkgs actual: dep zigpy-zboss pide zigpy<2, hay 2.1.0
  ];
}
