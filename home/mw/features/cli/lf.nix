{ pkgs, lib, ... }: {
  programs.lf = {
    enable = true;

    settings = {
      hidden = false;
      color256 = true;
      drawbox = true;
      icons = true;
      ignorecase = true;
    };

    commands = {
      mkdir = ''{{
        printf "Directory name: "
        read ans
        mkdir $ans
      }}'';

      mkfile = ''{{
        printf "File name: "
        read ans
        touch $ans
      }}'';

      doasmkfile = ''{{
        printf "File name: "
        read ans
        doas touch $ans
      }}'';
    };
  };
}
