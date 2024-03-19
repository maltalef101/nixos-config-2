{ lib, ...}: {
  services.xserver = {
		enable = true;
		autoRepeatDelay = lib.mkDefault 160;
		autoRepeatInterval = lib.mkDefault 50;
		displayManager.startx.enable = true;
		xkb = {
			options = lib.mkDefault "caps:swapescape";
			layout = lib.mkDefault "es";
		};
		
		libinput.mouse = {
			accelProfile = "flat";
			accelSpeed = "1";
		};
  };
}
