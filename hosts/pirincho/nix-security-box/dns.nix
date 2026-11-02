# Tools for DNS queries and enumeration

{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    aiodnsbrute
    amass
    bind
    dnsenum
    # dnsmon-go # sacado de nixpkgs: upstream archivó el proyecto (ago 2025)
    dnsmonster
    dnsrecon
    dnstake
    dnstracer
    dnstwist
    dnspeep
    dnsvalidator
    dnsx
    fierce
    findomain
    knockpy
    massdns
    subcat
    subfinder
    subprober
    subzerod
    wtfis
  ];
}
