{
  config,
  lib,
  pkgs,
  myLib,
  ...
}:
let
  inherit (builtins) attrValues;
  inherit (lib.modules) mkIf mkOverride;
  inherit (myLib) mkOverrideDefault;
in
{

  git-hooks = {
    enable = mkOverride 999 false;
    package = mkOverrideDefault pkgs.prek;
    excludes = [
      ".pre-commit-config.yaml"
      "^.devenv\..*/"
      "^.git/"
      "devenv.lock"
      "package-lock.json"
      "uv.lock"
    ];
    hooks.treefmt = {
      enable = mkOverrideDefault config.treefmt.enable;

      # if treefmt is enabled use preconfigured treefmt and formatters
      packageOverrides.treefmt = mkIf config.treefmt.enable config.treefmt.config.build.wrapper;
      settings.formatters = mkIf config.treefmt.enable (attrValues config.treefmt.config.build.programs);
    };
  };
}
