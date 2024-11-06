{ config, lib, pkgs, ...}: {
  boot = {
    tmp.cleanOnBoot = true;
    loader = {
      systemd-boot = { enable = true; editor = true; };
      efi = {
        canTouchEfiVariables = true;
        efiSysMountPoint = "/boot/efi";
      };
      timeout = 3;
    };
  };
}
