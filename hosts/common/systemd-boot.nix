{ config, lib, pkgs, ...}: {
  boot = {
    tmp.cleanOnBoot = true;
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
