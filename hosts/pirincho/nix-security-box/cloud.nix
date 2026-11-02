# Tools to work with cloud environments

{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    cloud-nuke
    cloudfox
    ec2stepshell
    gato
    gcp-scanner
    # ggshield
    goblob
    grimoire
    imdshift
    # pacu # roto en nixpkgs actual: awscli 1.x pide botocore y s3transfer más viejos
    poutine
    prowler
    yatas
  ];
}
