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

  cfg = config.knopki.xml;
in
{
  options.knopki.xml = {
    enable = mkEnableOption "Enable xml support";

    xmllint = {
      enable = mkEnableOption "Enable xmllint";
      package = mkPackageOption pkgs "libxml2" { };
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
      check-xml.enable = mkOverrideDefault true;
      xmllint = {
        enable = mkOverrideDefault cfg.xmllint.enable;
        package = mkOverrideDefault cfg.xmllint.package;
        name = "xmllint";
        entry = "xmllint";
        files = "\\.(xml|svg|xhtml|xsl|xslt|dtd|xsd)$";
      };
    };

    treefmt.config.programs = {
      xmllint = {
        enable = mkOverrideDefault cfg.xmllint.enable;
        package = mkOverrideDefault cfg.xmllint.package;
      };
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
