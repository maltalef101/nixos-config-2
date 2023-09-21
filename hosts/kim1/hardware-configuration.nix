{
  boot = {
    initrd = {
      availableKernelModules =
        [ "ohci_pci" "ehci_pci" "pata_amd" "ahci" "usbhid" "usb_storage" "sd_mod" "floppy" ];
      kernelModules = [ ];
    };
    kernelModules = [ "kvm-amd" ];
	extraModulePackages = [ ];
	grub.device = "/dev/sda";
  };

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-label/root";
      fsType = "ext4";
    };

    "/boot" = {
      device = "/dev/disk/by-label/boot";
      fsType = "ext4";
    };
  };

  swapDevices = [ { device = "/dev/disk/by-label/swap"; } ];

  networking.useDHCP = true;

  nixpkgs.hostPlatform.system = "x86_64-linux";
  hardware.cpu.amd.updateMicrocode = true;
}
