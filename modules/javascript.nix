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

  cfg = config.knopki.javascript;
in
{
  options.knopki.javascript = {
    enable = mkEnableOption "Enable javascript support";

    biome = {
      enable = mkEnableOption "Enable biome";
      package = mkPackageOption pkgs "biome" { };
    };
  };

  config = mkIf cfg.enable {
    packages = packagesFromConfigs [
      cfg.biome
    ];

    languages.javascript = {
      enable = mkDefault true;
    };

    git-hooks.hooks = {
      biome-js = {
        enable = mkDefault cfg.biome.enable;
        name = "Biome Javascript Lint";
        package = mkOverrideDefault cfg.biome.package;
        entry = mkDefault ''
          ${getExe cfg.biome.package} check --write --files-ignore-unknown=true --no-errors-on-unmatched
        '';
        files = mkDefault "\\.jsx?$";
      };
    };

    treefmt.config = {
      settings.formatter."biome-js" = mkIf cfg.biome.enable {
        command = getExe cfg.biome.package;
        options = [
          "format"
          "--write"
          "--files-ignore-unknown=true"
          "--no-errors-on-unmatched"
        ];
        includes = [
          "*.js"
          "*.jsx"
        ];
      };
    };

    knopki.menu.commands = commandsFromConfigs { category = "javascript"; } [
      cfg.biome
    ];
  };
}
