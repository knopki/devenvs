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
  inherit (lib.meta) getExe;
  inherit (myLib) commandsFromConfigs mkOverrideDefault packagesFromConfigs;

  cfg = config.knopki.css;
in
{
  options.knopki.css = {
    enable = mkEnableOption "Enable css support";

    biome = {
      enable = mkEnableOption "Enable biome";
      package = mkPackageOption pkgs "biome" { };
    };
  };

  config = mkIf cfg.enable {
    packages = packagesFromConfigs [
      cfg.biome
    ];

    git-hooks.hooks = {
      biome-css = {
        enable = mkDefault cfg.biome.enable;
        name = "Biome CSS Lint";
        package = mkOverrideDefault cfg.biome.package;
        entry = mkDefault ''
          ${getExe cfg.biome.package} check --write --files-ignore-unknown=true --no-errors-on-unmatched
        '';
        files = mkDefault "\\.css$";
      };
    };

    treefmt.config = {
      settings.formatter."biome-css" = mkIf cfg.biome.enable {
        command = getExe cfg.biome.package;
        options = [
          "format"
          "--write"
          "--files-ignore-unknown=true"
          "--no-errors-on-unmatched"
        ];
        includes = [ "*.css" ];
      };
    };

    knopki.menu.commands = commandsFromConfigs { category = "css"; } [
      cfg.biome
    ];
  };
}
