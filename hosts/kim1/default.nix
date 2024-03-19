{ pkgs, inputs, ... }: {
  imports = with inputs.hardware.nixosModules; [
    common-cpu-amd
    #common-gpu-nvidia
    common-pc-hdd

    ./hardware-configuration.nix
	./services

    ../common
    ../common/users/maltalef

    ../common/optional/auto-cpufreq.nix
    ../common/optional/grub.nix
    ../common/optional/thermald.nix
  ];

  nix.settings.auto-optimise-store = false;

  boot.kernelPackages = pkgs.linuxKernel.packages.linux_zen;
}
