{ pkgs, inputs, ... }: {
  imports = with inputs.hardware.nixosModules; [
     lenovo-thinkpad-e14-amd
     
    ./hardware-configuration.nix

    ../common
    ../common/users/maltalef
	../common/users/mw

	../common/optional/auto-cpufreq.nix
	../common/optional/brightness.nix
	../common/optional/gamemode.nix
	../common/optional/gdm.nix
	../common/optional/thermald.nix
	../common/optional/systemd-boot.nix
    ../common/optional/bluetooth.nix
    ../common/optional/networkmanager.nix
    ../common/optional/pipewire.nix
	../common/optional/hyprland.nix
  ];

  boot.kernelPackages = pkgs.linuxKernel.packages.linux_6_19;

  services.flatpak.enable = true;
  programs.dconf.enable = true;

  services.fwupd.enable = true;
  services.tlp = {
	enable = true;
	settings = {
		START_CHARGE_THRESH_BAT0 = 85;
		STOP_CHARGE_THRESH_BAT0 = 95;
		TPSMAPI_ENABLE = 1;

		CPU_ENERGY_PERF_POLICY_ON_AC = "performance";
		CPU_ENERGY_PERF_POLICY_ON_BAT = "power";
		CPU_ENERGY_PERF_POLICY_ON_SAV = "power";

		PLATFORM_PROFILE_ON_AC = "performance";
		PLATFORM_PROFILE_ON_BAT = "balanced";
		PLATFORM_PROFILE_ON_SAV = "low-power";

		CPU_SCALING_GOVERNOR_ON_AC = "performance";
		CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
		CPU_SCALING_GOVERNOR_ON_SAV = "powersave";

		CPU_HWP_DYN_BOOST_ON_AC = 1;
		CPU_HWP_DYN_BOOST_ON_BAT = 0;
		CPU_HWP_DYN_BOOST_ON_SAV = 0;
	};
  };

  services.logind.settings.Login = {
	  HandleLidSwitchExternalPower = "ignore";
  };

  services.fprintd.enable = true;
}
