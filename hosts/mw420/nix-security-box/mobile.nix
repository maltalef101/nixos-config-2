# Tools for working with Android/iOS devices

{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    abootimg
    androguard
    apkeep
    # apkleaks
    apktool
    dex2jar
    # genymotion # fetch roto: el instalador upstream devuelve 403 (URL retirada)
    ghost
    morf
    otadump
    payload-dumper-go
    scrcpy
    simg2img
    trueseeing
  ];
}
