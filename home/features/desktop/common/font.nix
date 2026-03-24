{ pkgs, lib, ... }: {
  home.packages = with pkgs; [
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-color-emoji
    fira-code
    fira-code-symbols
    nerd-fonts.fira-code
  ];

  fonts.fontconfig.enable = true;
}
