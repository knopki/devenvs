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
  inherit (myLib) commandsFromConfigs packagesFromConfigs;

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

    biome.enable = mkEnableOption "Enable biome";
  };

  config = mkIf cfg.enable {
    packages =
      packagesFromConfigs [
        cfg.jq
        cfg.fx
      ]
      ++ optional (
        config.treefmt.enable && config.treefmt.config.programs.formatjson5.enable
      ) config.treefmt.config.programs.formatjson5.package;

    git-hooks.hooks = {
      check-json.enable = mkDefault (!cfg.biome.enable);
      biome = mkIf cfg.biome.enable {
        enable = mkDefault true;
        types_or = mkDefault [
          "json"
          "json5"
        ];
      };
    };

    treefmt.config.programs = {
      formatjson5.enable = mkDefault (!cfg.biome.enable);
      biome = mkIf cfg.biome.enable {
        enable = mkDefault cfg.biome.enable;
        settings = {
          json = {
            formatter = {
              indentStyle = mkDefault "space";
            };
          };
        };
        includes = mkDefault [
          "*.json"
          "*.jsonc"
          "*.json5"
        ];
      };
    };

    knopki.menu.commands = commandsFromConfigs { category = "json"; } [
      cfg.jq
      cfg.fx
    ];
  };
}
