{
  config,
  lib,
  pkgs,
  myLib,
  ...
}:
let
  inherit (lib.modules) mkDefault mkIf;
  inherit (lib.options) mkEnableOption mkPackageOption;
  inherit (myLib) commandsFromConfigs packagesFromConfigs;

  cfg = config.knopki.security;
in
{
  options.knopki.security = {
    enable = mkEnableOption "Enable markdown support" // {
      default = cfg.grype.enable || cfg.syft.enable || cfg.trivy.enable;
    };

    grype = {
      enable = mkEnableOption "Enable grype - container vulnerability scanner";
      package = mkPackageOption pkgs "grype" { };
    };

    syft = {
      enable = mkEnableOption "Enable syft - Software Bill of Materials generator" // {
        default = cfg.grype.enable;
      };
      package = mkPackageOption pkgs "syft" { };
    };

    trivy = {
      enable = mkEnableOption "Enable trivy - security scanner";
      package = mkPackageOption pkgs "trivy" { };
    };
  };

  config = mkIf cfg.enable {
    packages = packagesFromConfigs [
      cfg.grype
      cfg.syft
      cfg.trivy
    ];

    git-hooks.hooks = {
      trivy-repository = {
        inherit (cfg.trivy) package;
        enable = mkDefault cfg.trivy.enable;
        name = "Trivy repository audit";
        pass_filenames = false;
        entry = "trivy repository .";
      };
    };

    knopki.menu.commands = commandsFromConfigs { category = "security"; } [
      cfg.grype
      cfg.syft
      cfg.trivy
    ];
  };
}
