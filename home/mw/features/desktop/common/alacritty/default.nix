{ lib, ... }: {
  programs.alacritty.enable = true;
  xdg.configFile."alacritty/alacritty.toml" = { source = lib.mkDefault ./alacritty.toml; };
}
