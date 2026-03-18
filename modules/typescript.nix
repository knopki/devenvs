{
  config,
  lib,
  ...
}:
let
  inherit (lib.modules) mkDefault mkIf;
  inherit (lib.options) mkEnableOption;

  cfg = config.knopki.typescript;
in
{
  options.knopki.typescript = {
    enable = mkEnableOption "Enable typescript support";

    biome.enable = mkEnableOption "Enable biome";
  };

  config = mkIf cfg.enable {
    languages.typescript = {
      enable = mkDefault true;
    };

    git-hooks.hooks = {
      biome = mkIf cfg.biome.enable {
        enable = mkDefault true;
        types_or = mkDefault [
          "ts"
          "tsx"
        ];
      };
    };

    treefmt.config.programs = {
      biome = mkIf cfg.biome.enable {
        enable = mkDefault cfg.biome.enable;
        includes = mkDefault [
          "*.mts"
          "*.ts"
          "*.tsx"
        ];
      };
    };
  };
}
