{ pkgs, inputs, ... }: {
  imports = with inputs.hardware.nixosModules; [
    common-cpu-intel
    common-gpu-intel
    common-pc-ssd

    ./hardware-configuration.nix

    ../common
    ../common/users/maltalef

	  ../common/optional/auto-cpufreq.nix
	  ../common/optional/brightness.nix
	  ../common/optional/gamemode.nix
	  ../common/optional/greetd.nix
	  ../common/optional/thermald.nix
    ../common/optional/bluetooth.nix
    ../common/optional/networkmanager.nix
    ../common/optional/pipewire.nix
    ../common/optional/xserver.nix
  ];

  boot.kernelPackages = pkgs.linuxKernel.packages.linux_zen;

  services.xserver.videoDrivers = [ "intel" ];
  services.xserver.deviceSection = ''
	Option "DRI" "2"
	Option "TearFree" "true"
  '';

  services.autorandr = {
    enable = true;
    profiles = {
      "docked" = {
        fingerprint = {
          eDP1 = "00ffffffffffff0009e50d0700000000011b0104951f11780224109759548e271e505400000001010101010101010101010101010101641b5677500013303020360035ad1000001a7017568c50003e303020360035ad1000001a000000fe004a56594336504e5431344e34310000000000004121960010000009010a202000a5";
          HDMI1 = "00ffffffffffff001e6d235acb4f0000081a010380331d78ea6275a3554fa027125054210800714081c08100818095009040a9c0b300023a801871382d40582c4500fe221100001e000000fd00383d1e530f000a202020202020000000fc0032334d5035350a202020202020000000ff000a202020202020202020202020015902031df14a900403011412051f1013230907078301000065030c001000023a801871382d40582c4500fe221100001e011d8018711c1620582c2500fe221100009e011d007251d01e206e285500fe221100001e8c0ad08a20e02d10103e9600fe22110000180000000000000000000000000000000000000000000000000000e6";
        };

        config = {
          eDP1 = {
            enable = true;
            mode = "1366x768";
            position = "0x352";
            rate = "60.00";
          };

          HDMI1 = {
            enable = true;
            primary = true;
            mode = "1920x1080";
            position = "1366x0";
            rate = "60.00";
          };
        };
      };
    };
  };

  services.ratbagd.enable = true;

  programs.dconf.enable = true;

  hardware.opengl = {
    enable = true;
    driSupport = true;
    driSupport32Bit = true;
  };

  services.logind = {
	  lidSwitchDocked = "ignore";
	  lidSwitchExternalPower = "ignore";
  };
}
