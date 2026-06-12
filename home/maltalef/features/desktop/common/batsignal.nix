{ pkgs, lib, ... }: {
  services.batsignal = {
	  enable = true;
	  extraArgs = [ "-w" "20" "-c" "10" "-d" "5" ];
  };
}
