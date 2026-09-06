{ lib, ... }: {
  time.timeZone = lib.mkDefault "America/Argentina/Buenos_Aires";
  i18n = {
    defaultLocale = lib.mkDefault "en_US.UTF-8";
    extraLocaleSettings = {
      LC_TIME = "es_AR.UTF-8";
    };
  };

  # us-intl con dead keys sólo en chords de AltGr; ' " ` ~ ^ tipean literal.
  # Esto lo lee la X de c64 y, vía useXkbConfig, también la consola
  # (ckbcomp traduce el layout xkb a keymap de tty). Hyprland no lo hereda:
  # cada user lo repite en input.kb_layout/kb_variant de su home.
  services.xserver.xkb = {
    layout = lib.mkDefault "us";
    variant = lib.mkDefault "altgr-intl";
    options = lib.mkDefault "caps:swapescape";
  };
  console.useXkbConfig = true;
}
