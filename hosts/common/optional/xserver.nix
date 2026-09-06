{ lib, ...}: {
  services.xserver = {
		enable = true;
		autoRepeatDelay = lib.mkDefault 160;
		autoRepeatInterval = lib.mkDefault 50;
		displayManager.startx.enable = true;

		libinput.mouse = {
			accelProfile = "flat";
			accelSpeed = "1";
		};
  };
}
