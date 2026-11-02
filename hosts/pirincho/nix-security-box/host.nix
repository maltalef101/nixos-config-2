# Host security tools

{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    checksec
    linux-exploit-suggester
    lynis
    # safety-cli # roto en nixpkgs actual: python3.14-safety marcado broken
    tracee
    vulnix
  ];
}
