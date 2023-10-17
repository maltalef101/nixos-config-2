{ config, pkgs, ... }:
let tex = (pkgs.texlive.combine { inherit (pkgs.texlive) scheme-medium; });
in { home.pacages = with pkgs; [ tex ]; }
