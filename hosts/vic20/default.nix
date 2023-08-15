{ pkgs, inputs, ... }: {
  imports = with inputs.hardware.nixosModules; [
    common-cpu-intel
    common-gpu-intel
    common-pc-ssd

    ./hardware-configuration.nix

    ../common
    ../common/users/maltalef.nix

    ../common/optional/wireless.nix
  ];

  boot.kernelPackages = pkgs.linuxKernel.packages.linux_zen;

  networking = { useDHCP = true; };
}
