{ lib, ...}: {
  services.xserver = {
		enable = true;
		layout = lib.mkDefault "es";
		displayManager.startx.enable = true;
		xkbOptions = lib.mkDefault "caps:swapescape";
		autoRepeatDelay = lib.mkDefault 160;
		autoRepeatInterval = lib.mkDefault 70;
		
		libinput.mouse = {
			accelProfile = "flat";
			accelSpeed = "1";
		};
  };
}
