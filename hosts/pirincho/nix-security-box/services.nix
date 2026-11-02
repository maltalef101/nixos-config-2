# Tools for testing various services (SSH, SNMP, etc.)

{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    # el pname no coincide con el nombre del proyecto (acltoolkit-ad) y el
    # pythonMetadataCheckPhase nuevo de nixpkgs falla el build
    (acltoolkit.overrideAttrs { dontCheckPythonMetadata = true; })
    checkip
    ghunt
    ike-scan
    keepwn
    metasploit
    nbutools
    nuclei
    nuclei-templates
    openrisk
    osv-scanner
    uncover
    traitor
    vuls

    # E-Mail
    mx-takeover
    ruler
    swaks
    trustymail

    # Databases
    agneyastra
    ghauri
    laudanum
    mongoaudit
    nosqli
    pysqlrecon
    sqlmap
    sqlmc

    # SNMP
    braa
    onesixtyone

    # SSH
    baboossh
    sshchecker
    ssh-audit
    ssh-mitm

    # IDS/IPS/WAF
    teler
    waf-tester
    wafw00f

    # Post-quantum
    tlsanalyzer
    cryptoscan
    mini-pqc
    pqc-bench
    pqcscan

    # CI
    oshka
    trajan

    # Terraform
    terrascan
    tfsec

    # Supply chain
    chain-bench
    witness
    
    # WebDAV
    davtest
  ];
}
