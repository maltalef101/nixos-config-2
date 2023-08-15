{ lib, ... }: {
  time.timeZone = lib.mkDefault "America/Argentina/Buenos_Aires";
  i18n = {
    defaultLocale = lib.mkDefault "en_US.UTF-8";
    extraLocaleSettings = {
      LC_TIME = "es_AR.UTF-8";
    };
  };
}
