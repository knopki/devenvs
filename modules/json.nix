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
      enable = mkEnableOption "Enable jq" // {
        default = true;
      };
      package = mkPackageOption pkgs "jq" { };
    };

    fx = {
      enable = mkEnableOption "Enable fx" // {
        default = true;
      };
      package = mkPackageOption pkgs "fx" { };
    };
  };

  config = mkIf cfg.enable {
    packages =
      packagesFromConfigs [
        cfg.jq
        cfg.fx
        config.git-hooks.hooks.denofmt
      ]
      ++ optional config.treefmt.enable config.treefmt.config.programs.formatjson5.package;

    git-hooks.hooks = {
      check-json.enable = mkDefault true;
      denofmt.enable = mkDefault true;
    };

    treefmt.config.programs = {
      deno.enable = mkDefault true;
      formatjson5.enable = mkDefault true;
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
      ];
  };
}
