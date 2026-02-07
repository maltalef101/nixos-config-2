{ pkgs, inputs, ... }: {
  imports = with inputs.hardware.nixosModules; [
     lenovo-thinkpad-x1
     
    ./hardware-configuration.nix

    ../common
    ../common/users/maltalef

	../common/optional/auto-cpufreq.nix
	../common/optional/brightness.nix
	../common/optional/gamemode.nix
	../common/optional/greetd.nix
	../common/optional/thermald.nix
	../common/optional/systemd-boot.nix
    ../common/optional/bluetooth.nix
    ../common/optional/networkmanager.nix
    ../common/optional/pipewire.nix
	../common/optional/hyprland.nix
	../common/optional/work/undef.nix
  ];

  boot.kernelPackages = pkgs.linuxKernel.packages.linux_zen;

  programs.dconf.enable = true;

  services.logind = {
	  lidSwitchDocked = "ignore";
	  lidSwitchExternalPower = "ignore";
  };
  services.fprintd.enable = true;
}
