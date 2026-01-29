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

  cfg = config.knopki.xml;
in
{
  options.knopki.xml = {
    enable = mkEnableOption "Enable xml support";

    xmllint = {
      enable = mkEnableOption "Enable xmllint";
      package =
        if config.treefmt.enable then
          mkPackageOption config.treefmt.config.programs.xmllint "package" { }
        else
          mkPackageOption pkgs "libxml2";
    };

    xmlstarlet = {
      enable = mkEnableOption "Enable xmlstarlet";
      package = mkPackageOption pkgs "xmlstarlet" { };
    };
  };

  config = mkIf cfg.enable {
    packages = packagesFromConfigs [
      cfg.xmllint
      cfg.xmlstarlet
    ];

    git-hooks.hooks = {
      check-xml.enable = mkDefault true;
    };

    treefmt.config.programs = {
      xmllint.enable = mkDefault cfg.xmllint.enable;
    };

    knopki.menu.commands =
      optional cfg.xmllint.enable {
        inherit (cfg.xmllint) package;
        name = "xmllint";
        category = "xml";
      }
      ++ commandsFromConfigs { category = "xml"; } [ cfg.xmlstarlet ];
  };
}
