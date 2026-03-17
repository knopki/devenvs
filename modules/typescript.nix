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

  cfg = config.knopki.typescript;
in
{
  options.knopki.typescript = {
    enable = mkEnableOption "Enable typescript support";

    biome = {
      enable = mkEnableOption "Enable biome";
      package = mkPackageOption pkgs "biome" { };
    };
  };

  config = mkIf cfg.enable {
    packages = packagesFromConfigs [
      cfg.biome
    ];

    languages.typescript = {
      enable = mkDefault true;
    };

    git-hooks.hooks = {
      biome-ts = {
        enable = mkDefault cfg.biome.enable;
        name = "Biome Typescript Lint";
        package = mkOverrideDefault cfg.biome.package;
        entry = mkDefault ''
          ${getExe cfg.biome.package} check --write --files-ignore-unknown=true --no-errors-on-unmatched
        '';
        files = mkDefault "\\.tsx?$";
      };
    };

    treefmt.config = {
      settings.formatter."biome-ts" = mkIf cfg.biome.enable {
        command = getExe cfg.biome.package;
        options = [
          "format"
          "--write"
          "--files-ignore-unknown=true"
          "--no-errors-on-unmatched"
        ];
        includes = [
          "*.ts"
          "*.tsx"
        ];
      };
    };

    knopki.menu.commands = commandsFromConfigs { category = "javascript"; } [
      cfg.biome
    ];
  };
}
