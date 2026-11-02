{ pkgs, ... }: {
  # CUPS con los drivers de HP (hplip); las USB se ven solas, sin avahi
  services.printing = {
    enable = true;
    drivers = [ pkgs.hplip ];
  };
  environment.systemPackages = [ pkgs.hplip ];
}
