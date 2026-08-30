# Tools and libraries to access hardware

{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    cantoolz
    # chipsec # build roto en nixpkgs actual: 2 tests fallan bajo python3.14 (string formatting)
    cmospwd
    esptool
    extrude
    gallia
    hachoir
    # nrfutil   # unfree license
    packetry
    teensy-loader-cli
    termineter
    tytools
    python3Packages.python-can
    python3Packages.pyi2cflash
    python3Packages.pyspiflash
    # routersploit
  ];

  # nixpkgs.config.segger-jlink.acceptLicense = true;
}
