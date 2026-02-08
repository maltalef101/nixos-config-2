{ pkgs, inputs, ...}: {
	services.hyprsunset = {
		enable = true;
		settings = {
			profile = [
				{
					time = "8:00";
					temperature = 6000;
				}
				{
					time = "17:00";
					temperature = 4500;
				}
			];
		};
	};
}
