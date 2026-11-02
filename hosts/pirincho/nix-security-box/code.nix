# Code analysing tools, incl. search for secrets and alike in code

{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    betterleaks
    bomber-go
    cargo-audit
    credential-detector
    # deepsecrets # roto en nixpkgs actual: arrastra pydantic 1.x, sin soporte python3.14
    detect-secrets
    freeze
    # garble
    git-secret
    gitjacker
    gitleaks
    gitls
    gitxray
    gokart
    osv-detector
    packj
    pip-audit
	# safety-cli # roto en nixpkgs actual: python3.14-safety marcado broken
    qbom
    search-vulns
    secrethound
    secretscanner
    skjold
    tell-me-your-secrets
    trufflehog
    # whispers # roto en nixpkgs actual: semgrep-core aborta en patchelf
    xeol
  ];
}
