{ pkgs, ... }: {
  fontProfiles = {
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

  home.packages = with pkgs; [
    fira-code-symbols
    noto-fonts-emoji
    noto-fonts-cjk
  ];
}
