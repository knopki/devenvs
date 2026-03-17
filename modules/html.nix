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

  cfg = config.knopki.html;
in
{
  options.knopki.html = {
    enable = mkEnableOption "Enable html support";

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
      biome-html = {
        enable = mkDefault cfg.biome.enable;
        name = "Biome HTML Lint";
        package = mkOverrideDefault cfg.biome.package;
        entry = mkDefault ''
          ${getExe cfg.biome.package} check --write --files-ignore-unknown=true --no-errors-on-unmatched
        '';
        files = mkDefault "\\.(html?|svelte)$";
      };
    };

    treefmt.config = {
      settings.formatter."biome-html" = mkIf cfg.biome.enable {
        command = getExe cfg.biome.package;
        options = [
          "format"
          "--write"
          "--files-ignore-unknown=true"
          "--no-errors-on-unmatched"
        ];
        includes = [
          "*.html"
          "*.htm"
          "*.svelte"
        ];
      };
    };

    knopki.menu.commands = commandsFromConfigs { category = "html"; } [
      cfg.biome
    ];
  };
}
