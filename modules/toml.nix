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
  inherit (config.lib) mkOverrideDefault;
  inherit (myLib) commandsFromConfigs packagesFromConfigs;

  cfg = config.knopki.toml;
in
{
  options.knopki.toml = {
    enable = mkEnableOption "Enable toml support";

    taplo = {
      enable = mkEnableOption "Enable taplo";
      package = mkPackageOption pkgs "taplo" { };
    };
  };

  config = mkIf cfg.enable {
    packages = packagesFromConfigs [ cfg.taplo ];

    git-hooks.hooks = {
      check-toml.enable = mkDefault true;
      taplo = {
        enable = mkDefault cfg.taplo.enable;
        package = mkOverrideDefault cfg.taplo.package;
      };
    };

    treefmt.config.programs = {
      taplo = {
        enable = mkDefault cfg.taplo.enable;
        package = mkOverrideDefault cfg.taplo.package;
      };
    };

    knopki.menu.commands = commandsFromConfigs { category = "toml"; } [ cfg.taplo ];
  };
}
