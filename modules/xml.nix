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

  cfg = config.knopki.xml;
in
{
  options.knopki.xml = {
    enable = mkEnableOption "Enable xml support";

    xmllint = {
      enable = mkEnableOption "Enable xmllint" // {
        default = true;
      };
      package = mkPackageOption pkgs "libxml2" { };
    };

    xmlstarlet = {
      enable = mkEnableOption "Enable xmlstarlet" // {
        default = true;
      };
      package = mkPackageOption pkgs "xmlstarlet" { };
    };
  };

  config = mkIf cfg.enable {
    packages =
      optional cfg.xmllint.enable cfg.xmllint.package
      ++ optional cfg.xmlstarlet.enable cfg.xmlstarlet.package;

    git-hooks.hooks = {
      check-xml.enable = mkDefault true;
    };

    treefmt.config.programs = {
      xmllint = {
        enable = mkDefault cfg.xmllint.enable;
        package = cfg.xmllint.package;
      };
    };
  };
}
