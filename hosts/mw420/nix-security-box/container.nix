# Container analysing tools

{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    cdk-go
    clair
    cliam
    cloudlist
    dive
    dockle
    fwanalyzer
    grype
    trivy
    # roto en nixpkgs actual: unblob arrastra python fs (pyfilesystem2), sin
    # soporte python3.14
    # (unblob.overrideAttrs (old: {
    #   # upstream bug: btrfs_stream test fails with EXDEV in nix sandbox (cross-device rename)
    #   disabledTests = (old.disabledTests or []) ++ [ "test_all_handlers[filesystem.btrfs_stream]" ];
    # }))
    varunastra
  ];
}
