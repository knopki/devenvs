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
      check-yaml.enable = mkDefault true;
      denofmt.enable = mkDefault true;
      yamllint = {
        enable = mkDefault cfg.yamllint.enable;
        package = mkOverrideDefault cfg.yamllint.package;
        settings.configuration = mkDefault ''
          rules:
            comments:
              min-spaces-from-content: 1
        '';
      };
    };

    treefmt.config.programs = {
      deno.enable = mkDefault true;
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
