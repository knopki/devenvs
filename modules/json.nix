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
  inherit (lib.lists) optional;
  inherit (lib.meta) getExe;
  inherit (myLib) commandsFromConfigs mkOverrideDefault packagesFromConfigs;

  cfg = config.knopki.json;
in
{
  options.knopki.json = {
    enable = mkEnableOption "Enable json support";

    jq = {
      enable = mkEnableOption "Enable jq";
      package = mkPackageOption pkgs "jq" { };
    };

    fx = {
      enable = mkEnableOption "Enable fx";
      package = mkPackageOption pkgs "fx" { };
    };

    biome = {
      enable = mkEnableOption "Enable biome";
      package = mkPackageOption pkgs "biome" { };
    };
  };

  config = mkIf cfg.enable {
    packages =
      packagesFromConfigs [
        cfg.jq
        cfg.fx
        cfg.biome
      ]
      ++ optional (
        config.treefmt.enable && config.treefmt.config.programs.formatjson5.enable
      ) config.treefmt.config.programs.formatjson5.package;

    git-hooks.hooks = {
      check-json.enable = mkDefault (!cfg.biome.enable);
      biome-json = {
        enable = mkDefault cfg.biome.enable;
        name = "Biome JSON Lint";
        package = mkOverrideDefault cfg.biome.package;
        entry = mkDefault ''
          ${getExe cfg.biome.package} check --write --files-ignore-unknown=true --no-errors-on-unmatched
        '';
        files = mkDefault "\\.json(c|5)?$";
      };
    };

    treefmt.config = {
      programs.formatjson5.enable = mkDefault (!cfg.biome.enable);
      settings.formatter."biome-json" = mkIf cfg.biome.enable {
        command = getExe cfg.biome.package;
        options = [
          "format"
          "--write"
          "--files-ignore-unknown=true"
          "--no-errors-on-unmatched"
        ];
        includes = [
          "*.json"
          "*.jsonc"
          "*.json5"
        ];
      };
    };

    knopki.menu.commands =
      optional config.git-hooks.hooks.denofmt.enable {
        inherit (config.git-hooks.hooks.denofmt) package;
        name = "deno fmt";
        category = "json";
      }
      ++ optional config.treefmt.enable {
        inherit (config.treefmt.config.programs.formatjson5) package;
        category = "json";
      }
      ++ commandsFromConfigs { category = "json"; } [
        cfg.jq
        cfg.fx
        cfg.biome
      ];
  };
}
