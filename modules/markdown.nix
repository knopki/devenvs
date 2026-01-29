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

  cfg = config.knopki.markdown;
in
{
  options.knopki.markdown = {
    enable = mkEnableOption "Enable markdown support";

    glow = {
      enable = mkEnableOption "Enable glow viewer";
      package = mkPackageOption pkgs "glow" { };
    };

    lychee = {
      enable = mkEnableOption "Enable lychee linter";
      package = mkPackageOption config.git-hooks.hooks.lychee "package" { };
    };

    marksman = {
      enable = mkEnableOption "Enable marksman";
      package = mkPackageOption pkgs "marksman" { };
    };

    markdownlint = {
      enable = mkEnableOption "Enable markdownlint";
      package = mkPackageOption config.git-hooks.hooks.markdownlint "package" { };
    };
  };

  config = mkIf cfg.enable {
    packages = packagesFromConfigs [
      cfg.glow
      cfg.lychee
      cfg.marksman
      cfg.markdownlint
    ];

    git-hooks.hooks = {
      lychee.enable = mkDefault cfg.lychee.enable;
      denofmt.enable = mkDefault true;
      markdownlint = {
        enable = mkDefault cfg.markdownlint.enable;
        settings.configuration = mkDefault {
          MD013 = {
            tables = false;
          };
        };
      };
    };

    treefmt.config.programs = {
      deno.enable = mkDefault true;
    };

    knopki.menu.commands =
      commandsFromConfigs { category = "markdown"; } [
        cfg.glow
        cfg.lychee
        cfg.marksman
        cfg.markdownlint
      ]
      ++ optional config.git-hooks.hooks.denofmt.enable {
        inherit (config.git-hooks.hooks.denofmt) package;
        name = "deno fmt";
        category = "markdown";
      };
  };
}
