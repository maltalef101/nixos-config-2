{ pkgs, lib, ... }: {
  home.packages = [ pkgs.redshift ];
  services.redshift = {
    enable = true;
    enableVerboseLogging = true;

    provider = "manual";
    latitude = lib.mkDefault "-34.6";
    longitude = lib.mkDefault "-58.4";

    temperature = {
      day = 5500;
      night = 3650;
    };

    settings.redshift = {
      adjustment-method = "randr";
      fade = 1;
      gamma-night = 0.90;
    };
  };
}
