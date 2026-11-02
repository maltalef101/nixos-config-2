# Tools for informtion gathering

{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    cloudbrute
    enumerepo
    holehe
    lse
    # maigret  # insecure
    metabigor
    # p0f
    raccoon-scanner
    sherlock
    sn0int
    socialscan
    theharvester
    urlhunter
  ];
}
