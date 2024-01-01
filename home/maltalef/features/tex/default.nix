{ config, pkgs, ... }:
let
  tex = (pkgs.texlive.combine {
    inherit (pkgs.texlive)
      biblatex scheme-medium wrapfig amsmath ulem hyperref capt-of dvisvgm
      dvipng enumitem titlesec;
  });
in { home.packages = with pkgs; [ tex ]; }
