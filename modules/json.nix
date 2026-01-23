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
    packages = optional cfg.jq.enable cfg.jq.package ++ optional cfg.fx.enable cfg.fx.package;

    git-hooks.hooks = {
      check-json.enable = mkDefault true;
      denofmt.enable = mkDefault true;
    };

    treefmt.config.programs = {
      deno.enable = mkDefault true;
      formatjson5.enable = mkDefault true;
    };

    knopki.menu.commands = map (cmd: cmd // { category = "json"; }) (
      [
        {
          package = config.git-hooks.hooks.denofmt.package;
          name = "deno fmt";
        }
        {
          package = config.treefmt.config.programs.formatjson5.package;
        }
      ]
      ++ optional cfg.jq.enable {
        package = cfg.jq.package;
      }
      ++ optional cfg.fx.enable {
        package = cfg.fx.package;
      }
    );
  };
}
