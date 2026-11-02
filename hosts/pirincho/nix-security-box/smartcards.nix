# Smartcard tools

{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    # cardpeek # broken
    libfreefare
    mfcuk
    mfoc
    python3Packages.emv
  ];
}
