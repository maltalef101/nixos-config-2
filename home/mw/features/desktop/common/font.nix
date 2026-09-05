{ pkgs, lib, ... }: {
  home.packages = with pkgs; [
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-color-emoji
    # font de UI que piden GTK y el portal (default de gsettings-desktop-schemas);
    # si falta, fontconfig sustituye cualquier sans y firefox cae a serif
    adwaita-fonts
    fira-code
    fira-code-symbols
    nerd-fonts.fira-code
  ];

  fonts.fontconfig.enable = true;
}
