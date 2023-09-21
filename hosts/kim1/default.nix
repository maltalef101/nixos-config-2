{ pkgs, inputs, ... }: {
  imports = with inputs.hardware.nixosModules; [
    common-cpu-amd
    #common-gpu-nvidia
    common-pc-hdd

    ./hardware-configuration.nix

    ../common
    ../common/users/maltalef

    ../common/optional/auto-cpufreq.nix
    ../common/optional/grub.nix
    ../common/optional/thermald.nix
  ];

  boot.kernelPackages = pkgs.linuxKernel.packages.linux_zen;
}
