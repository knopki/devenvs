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
  inherit (lib.lists) optional optionals;
  inherit (myLib) commandsFromConfigs mkOverrideDefault packagesFromConfigs;

  cfg = config.knopki.yaml;
in
{
  options.knopki.yaml = {
    enable = mkEnableOption "Enable yaml support";

    format.enable = mkEnableOption "Enable yaml formatting";

    lsp = {
      enable = mkEnableOption "Enable yaml LS";
      package = mkPackageOption pkgs "yaml-language-server" { };
    };

    yamllint = {
      enable = mkEnableOption "Enable yamllint";
      package = mkPackageOption pkgs "yamllint" { };
    };
  };

  config = mkIf cfg.enable {
    packages = packagesFromConfigs [
      cfg.lsp
      cfg.yamllint
    ];

    git-hooks.hooks = {
      check-yaml.enable = mkDefault true;
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
      dprint = mkIf cfg.format.enable {
        enable = mkDefault cfg.format.enable;
        includes = optionals cfg.format.enable [
          "*.yml"
          "*.yaml"
        ];
        settings.plugins = pkgs.dprint-plugins.getPluginList (
          ps: optional cfg.format.enable ps.g-plane-pretty_yaml
        );
      };
    };

    knopki.menu.commands = commandsFromConfigs { category = "yaml"; } [
      cfg.lsp
      cfg.yamllint
    ];
  };
}
