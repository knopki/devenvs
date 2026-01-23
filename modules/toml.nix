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

  cfg = config.knopki.toml;
in
{
  options.knopki.toml = {
    enable = mkEnableOption "Enable toml support";

    taplo = {
      enable = mkEnableOption "Enable taplo" // { default = true; };
      package = mkPackageOption pkgs "taplo" {};
    };
  };

  config = mkIf cfg.enable {
    packages = optional cfg.taplo.enable cfg.taplo.package;

    git-hooks.hooks = {
      check-toml.enable = mkDefault true;
      taplo.enable = mkDefault true;
    };

    treefmt.config.programs = {
      taplo.enable = mkDefault true;
    };
  };
}
