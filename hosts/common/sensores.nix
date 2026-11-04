{ lib, ... }:
let
  inherit (lib) mkOption types;
in {
  # El sensor de temperatura del CPU del host, para las waybar de los homes (las leen por osConfig). Va por el
  # directorio del dispositivo (hwmon-path-abs de waybar) y no por /sys/class/hwmon/hwmonN, cuyo número cambia entre
  # arranques, ni por thermal-zone, que en la mayoría de las laptops no es el CPU. Sin la opción (null), la waybar no
  # muestra la temperatura: thermal-zone = 0 suele ser acpitz, una temperatura de la placa que pasaría por la del CPU.
  options.sensores.temperaturaCpu = mkOption {
    type = types.nullOr (types.submodule {
      options = {
        hwmon = mkOption {
          type = types.str;
          example = "/sys/devices/pci0000:00/0000:00:18.3/hwmon";
          description = "El directorio `hwmon` del dispositivo del sensor (el que contiene `hwmonN`).";
        };
        entrada = mkOption {
          type = types.str;
          default = "temp1_input";
          description = "El archivo de la temperatura dentro de `hwmonN`.";
        };
      };
    });
    default = null;
    description = "El sensor de temperatura del CPU (hwmon), o null si el host no lo declara.";
  };
}
