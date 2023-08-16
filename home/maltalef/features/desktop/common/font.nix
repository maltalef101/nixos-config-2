{ pkgs, lib, config, ... }: 
let
  cfg = {
    enable = true;
    monospace = {
      family = "FiraCode Nerd Font";
      package = pkgs.nerdfonts.override { fonts = [ "FiraCode" ]; };
    };

    regular = {
      family = "Noto Sans";
      package = pkgs.noto-fonts;
    };
  };
in
{
  config = lib.mkIf cfg.enable {
	fonts.fontconfig.enable = true;
    home.packages = with pkgs; [
	  cfg.monospace.package
  	  cfg.regular.package
      fira-code-symbols
      noto-fonts-emoji
      noto-fonts-cjk
    ];
  };
}
