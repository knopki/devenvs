{
  config,
  lib,
  pkgs,
  myLib,
  ...
}:
let
  inherit (builtins) attrValues toJSON;
  inherit (lib.modules) mkIf mkOverride;
  inherit (lib.strings) optionalString;
  inherit (myLib) mkOverrideDefault;
  writeJSON = name: obj: toString (pkgs.writeText name (toJSON obj));
in
{

  git-hooks = {
    enable = mkOverride 999 false;
    package = mkOverrideDefault pkgs.prek;
    excludes = [
      ".pre-commit-config.yaml"
      "^.devenv\..*/"
      "^.git/"
      "devenv.lock"
      "package-lock.json"
      "uv.lock"
    ];
    hooks = {
      biome = {
        settings.configPath = optionalString (
          config.treefmt.enable && config.treefmt.config.programs.biome.enable
        ) (writeJSON "biome.json" config.treefmt.config.programs.biome.settings);
      };

      treefmt = {
        enable = mkOverrideDefault config.treefmt.enable;

        # if treefmt is enabled use preconfigured treefmt and formatters
        packageOverrides.treefmt = mkIf config.treefmt.enable config.treefmt.config.build.wrapper;
        settings.formatters = mkIf config.treefmt.enable (attrValues config.treefmt.config.build.programs);
      };
    };
  };
}
