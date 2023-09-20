{
  boot = {
    initrd = {
      availableKernelModules =
        [ "ehci_pci" "ahci" "xhci_pci" "usbhid" "usb_storage" "sd_mod" ];
      kernelModules = [ "nvidia" ];
    };
    kernelModules = [ "kvm-intel" ];
    kernelParams = [ "nomodeset" ];
    blacklistedKernelModules = [ "nouveau" ];
  };

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-label/root";
      fsType = "ext4";
    };

    "/boot/efi" = {
      device = "/dev/disk/by-label/boot";
      fsType = "vfat";
    };

    "/var/lib/mount/storage" = {
 	    device = "/dev/disk/by-uuid/4c027f79-0f18-4776-9884-e6885849f2b3";
	    fsType = "ext4";
    };
  };

  swapDevices = [ { device = "/dev/disk/by-label/swap"; } ];

  networking.useDHCP = true;

  nixpkgs.hostPlatform.system = "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = true;
}
