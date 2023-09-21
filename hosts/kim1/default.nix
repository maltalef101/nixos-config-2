{ pkgs, inputs, ... }: {
  imports = with inputs.hardware.nixosModules; [
    common-cpu-amd
    common-gpu-amd
    common-pc-ssd

    ./hardware-configuration.nix

    ../common
    ../common/users/maltalef

    ../common/optional/auto-cpufreq.nix
    ../common/optional/thermald.nix
    ../common/optional/xserver.nix
  ];

  boot.kernelPackages = pkgs.linuxLatest;
}
