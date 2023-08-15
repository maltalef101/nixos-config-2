{ config, lib, pkgs, ...}:
{
  boot = {
    cleanTmpDir = true;
    loader = lib.mkDefault {
      systemd-boot = { enable = true; editor = false; };
      efi = {
        canTouchEfiVairables = true;
        efiSysMountPoint = "/boot/efi";
      };
      timeout = 3;
    };
  };
}
