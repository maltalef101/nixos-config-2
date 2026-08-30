# Forensic tools

{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    afflib
    amoco
    # acquire # roto en nixpkgs actual: dissect-target sin soporte python3.14
    dcfldd
    ddrescue
    dislocker
    dismember
    exiv2
    ext4magic
    extundelete
    foremost
    gef
    gzrt
    hivex
    hstsparser
    noseyparker
    ntfs3g
    ntfsprogs
    nwipe
    recoverjpeg
    safecopy
    sleuthkit
    srm
    stegseek
    testdisk
    volatility3
    wipe
    xorex
  ];
}
