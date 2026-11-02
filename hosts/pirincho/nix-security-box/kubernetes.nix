# Kubernetes infrastructure

{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    cfripper
    # checkov # roto en nixpkgs actual: falla un test de bc-detect-secrets (unidiff)
    cirrusgo
    kdigger
    kube-hunter
    kube-score
    kubeaudit
    kubestroyer
    kubescape
    popeye
  ];
}
