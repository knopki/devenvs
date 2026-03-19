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
  inherit (myLib) commandsFromConfigs mkOverrideDefault packagesFromConfigs;

  cfg = config.knopki.markdown;
in
{
  options.knopki.markdown = {
    enable = mkEnableOption "Enable markdown support";

    format.enable = mkEnableOption "Enable markdown formatting";

    glow = {
      enable = mkEnableOption "Enable glow viewer";
      package = mkPackageOption pkgs "glow" { };
    };

    lychee = {
      enable = mkEnableOption "Enable lychee linter";
      package = mkPackageOption pkgs "lychee" { };
    };

    marksman = {
      enable = mkEnableOption "Enable marksman";
      package = mkPackageOption pkgs "marksman" { };
    };

    markdownlint = {
      enable = mkEnableOption "Enable markdownlint";
      package = mkPackageOption pkgs.nodePackages "markdownlint-cli" { };
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
      lychee = {
        enable = mkDefault cfg.lychee.enable;
        package = mkOverrideDefault cfg.lychee.package;
      };
      markdownlint = {
        enable = mkDefault cfg.markdownlint.enable;
        package = mkOverrideDefault cfg.markdownlint.package;
        settings.configuration = mkDefault {
          MD013 = {
            tables = false;
          };
        };
      };
    };

    treefmt.config.programs = {
      dprint = mkIf cfg.format.enable {
        enable = mkDefault cfg.format.enable;
        includes = optional cfg.format.enable "*.md";
        settings.plugins = pkgs.dprint-plugins.getPluginList (
          ps: optional cfg.format.enable ps.dprint-plugin-markdown
        );
      };
    };

    knopki.menu.commands = commandsFromConfigs { category = "markdown"; } [
      cfg.glow
      cfg.lychee
      cfg.marksman
      cfg.markdownlint
    ];
  };
}
