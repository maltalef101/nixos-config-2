{ pkgs, lib, config, ...}: 
{
  programs.ssh = {
    enable = true;
    # overrides locales por máquina (hosts internos o transitorios que no
    # corresponde publicar en el repo); ssh ignora el archivo si no existe
    includes = [ "config.local" ];
  };
}
