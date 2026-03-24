{ pkgs, inputs, ...}: {
	services.hyprsunset = {
		enable = true;
		settings = {
			profile = [
				{
					time = "11:00";
					temperature = 6000;
				}
				{
					time = "20:00";
					temperature = 4500;
				}
			];
		};
	};
}
