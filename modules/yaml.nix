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

  cfg = config.knopki.yaml;
in
{
  options.knopki.yaml = {
    enable = mkEnableOption "Enable yaml support";

    yamllint = {
      enable = mkEnableOption "Enable yamllint" // {
        default = true;
      };
      package = mkPackageOption pkgs "yamllint" { };
    };

    yamlfmt = {
      enable = mkEnableOption "Enable yamlfmt" // {
        default = true;
      };
      package = mkPackageOption pkgs "yamlfmt" { };
    };
  };

  config = mkIf cfg.enable {
    packages =
      optional cfg.yamllint.enable cfg.yamllint.package
      ++ optional cfg.yamlfmt.enable cfg.yamlfmt.package;

    git-hooks.hooks = {
      check-yaml.enable = mkDefault true;
      yamllint = {
        enable = mkDefault cfg.yamllint.enable;
        package = cfg.yamllint.package;
      };
      yamlfmt = {
        enable = mkDefault cfg.yamlfmt.enable;
        package = cfg.yamlfmt.package;
      };
    };

    treefmt.config.programs = {
      yamlfmt = {
        enable = mkDefault cfg.yamlfmt.enable;
        package = cfg.yamlfmt.package;
      };
    };
  };
}
