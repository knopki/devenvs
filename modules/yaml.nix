{
  config,
  lib,
  pkgs,
  myLib,
  ...
}:
let
  inherit (lib.modules) mkIf;
  inherit (lib.options) mkEnableOption mkPackageOption;
  inherit (lib.lists) optional;
  inherit (config.lib) mkOverrideDefault;
  inherit (myLib) commandsFromConfigs packagesFromConfigs;

  cfg = config.knopki.yaml;
in
{
  options.knopki.yaml = {
    enable = mkEnableOption "Enable yaml support";

    yamllint = {
      enable = mkEnableOption "Enable yamllint";
      package = mkPackageOption pkgs "yamllint" { };
    };
  };

  config = mkIf cfg.enable {
    packages = packagesFromConfigs [
      cfg.yamllint
    ];

    git-hooks.hooks = {
      check-yaml.enable = mkOverrideDefault true;
      denofmt.enable = mkOverrideDefault true;
      yamllint = {
        enable = mkOverrideDefault cfg.yamllint.enable;
        package = mkOverrideDefault cfg.yamllint.package;
        settings.configuration = mkOverrideDefault ''
          rules:
            comments:
              min-spaces-from-content: 1
        '';
      };
    };

    treefmt.config.programs = {
      deno.enable = mkOverrideDefault true;
    };

    knopki.menu.commands =
      optional (config.git-hooks.enable && config.git-hooks.hooks.denofmt.enable) {
        inherit (config.git-hooks.hooks.denofmt) package;
        name = "deno fmt";
        category = "yaml";
      }
      ++ commandsFromConfigs { category = "yaml"; } [
        cfg.yamllint
      ];
  };
}
