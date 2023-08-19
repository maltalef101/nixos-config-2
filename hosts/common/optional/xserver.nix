{ lib, ...}: {
  services.xserver = {
		enable = true;
		layout = lib.mkDefault "es";
		autoRepeatDelay = lib.mkDefault 160;
		autoRepeatInterval = lib.mkDefault 50;
		displayManager.startx.enable = true;
		xkbOptions = lib.mkDefault "caps:swapescape";
		
		libinput.mouse = {
			accelProfile = "flat";
			accelSpeed = "1";
		};
  };
}
