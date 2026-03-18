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
  inherit (lib.meta) getExe;
  inherit (myLib) commandsFromConfigs mkOverrideDefault packagesFromConfigs;

  cfg = config.knopki.toml;
in
{
  options.knopki.toml = {
    enable = mkEnableOption "Enable toml support";

    taplo = {
      enable = mkEnableOption "Enable taplo (deprecated)";
      package = mkPackageOption pkgs "taplo" { };
    };

    tombi = {
      enable = mkEnableOption "Enable tombi";
      package = mkPackageOption pkgs "tombi" { };
    };
  };

  config = mkIf cfg.enable {
    packages = packagesFromConfigs [
      cfg.taplo
      cfg.tombi
    ];

    git-hooks.hooks = {
      check-toml.enable = mkDefault true;
      taplo = {
        enable = mkDefault (cfg.taplo.enable && !config.treefmt.enable);
        package = mkOverrideDefault cfg.taplo.package;
      };
      tombi-check = {
        enable = mkDefault cfg.tombi.enable;
        name = "Tombi TOML lint";
        package = mkOverrideDefault cfg.tombi.package;
        entry = mkDefault ''
          ${getExe cfg.tombi.package} lint
        '';
        files = mkDefault "\\.toml$";
      };
      tombi-format = {
        enable = mkDefault (cfg.tombi.enable && !config.treefmt.enable);
        name = "Tombi TOML formatter";
        package = mkOverrideDefault cfg.tombi.package;
        entry = mkDefault ''
          ${getExe cfg.tombi.package} format --check
        '';
        files = mkDefault "\\.toml$";
      };

    };

    treefmt.config = {
      programs.taplo = {
        enable = mkDefault cfg.taplo.enable;
        package = mkOverrideDefault cfg.taplo.package;
      };
      settings.formatter.tombi = mkIf cfg.tombi.enable {
        command = "${getExe cfg.tombi.package}";
        options = [
          "format"
        ];
        includes = [ "*.toml" ];
      };

    };

    knopki.menu.commands = commandsFromConfigs { category = "toml"; } [
      cfg.taplo
      cfg.tombi
    ];
  };
}
