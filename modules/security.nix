{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib.modules) mkDefault mkIf;
  inherit (lib.options) mkEnableOption mkPackageOption;
  inherit (lib.lists) optional;
  inherit (lib.meta) getExe;

  cfg = config.knopki.security;
in
{
  options.knopki.security = {
    enable = mkEnableOption "Enable markdown support" // {
      default = cfg.grype.enable or cfg.syft.enable or cfg.trivy.enable;
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
    packages =
      optional cfg.grype.enable cfg.grype.package
      ++ optional cfg.syft.enable cfg.syft.package
      ++ optional cfg.trivy.enable cfg.trivy.package;

    git-hooks.hooks = {
      trivy-repository = {
        inherit (cfg.trivy) package;
        enable = mkDefault cfg.trivy.enable;
        name = "Trivy repository audit";
        pass_filenames = false;
        entry = ''
          ${getExe cfg.trivy.package} repository "${config.git.root}"
        '';
      };
    };

    knopki.menu.commands = map (cmd: cmd // { category = "security"; }) (
      optional cfg.grype.enable {
        inherit (cfg.grype) package;
      }
      ++ optional cfg.syft.enable {
        inherit (cfg.syft) package;
      }
      ++ optional cfg.trivy.enable {
        inherit (cfg.trivy) package;
      }
    );

    enterShell = ''
      echo ${config.git.root}
    '';
  };
}
