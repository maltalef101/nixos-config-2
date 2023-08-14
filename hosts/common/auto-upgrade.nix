{ config, inputs, pkg, lib, ... }:
let
  inherit (config.networking) hostname;

  isClean = inputs.self ? rev;
in
{
  system.autoUpgrade = {
    enable = isClean;
    dates = "daily";
    flags = [
      "--refresh"
    ];
    channel = "https://nixos.org/channels/nixos-unstable";
  };
}
