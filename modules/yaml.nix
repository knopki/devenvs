{
  config,
  lib,
  myLib,
  ...
}:
let
  inherit (lib.modules) mkDefault mkIf;
  inherit (lib.options) mkEnableOption mkPackageOption;
  inherit (lib.lists) optional;
  inherit (myLib) commandsFromConfigs packagesFromConfigs;

  cfg = config.knopki.yaml;
in
{
  options.knopki.yaml = {
    enable = mkEnableOption "Enable yaml support";

    yamllint = {
      enable = mkEnableOption "Enable yamllint" // {
        default = true;
      };
      package = mkPackageOption config.git-hooks.hooks.yamllint "package" { };
    };
  };

  config = mkIf cfg.enable {
    packages = packagesFromConfigs [
      cfg.yamllint
      config.git-hooks.hooks.denofmt
    ];

    git-hooks.hooks = {
      check-yaml.enable = mkDefault true;
      denofmt.enable = mkDefault true;
      yamllint = {
        enable = mkDefault cfg.yamllint.enable;
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
      optional config.git-hooks.hooks.denofmt.enable {
        inherit (config.git-hooks.hooks.denofmt) package;
        name = "deno fmt";
        category = "yaml";
      }
      ++ commandsFromConfigs { category = "yaml"; } [
        cfg.yamllint
      ];
  };
}
