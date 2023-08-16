{ config, lib, pkgs, ...}: {
  boot = {
    cleanTmpDir = true;
    loader = {
      systemd-boot = { enable = true; editor = false; };
      efi = {
        canTouchEfiVariables = true;
        efiSysMountPoint = "/boot/efi";
      };
      timeout = 3;
    };
  };
}
