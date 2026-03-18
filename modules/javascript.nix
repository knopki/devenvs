{
  config,
  lib,
  ...
}:
let
  inherit (lib.modules) mkDefault mkIf;
  inherit (lib.options) mkEnableOption;

  cfg = config.knopki.javascript;
in
{
  options.knopki.javascript = {
    enable = mkEnableOption "Enable javascript support";

    biome.enable = mkEnableOption "Enable biome";
  };

  config = mkIf cfg.enable {
    languages.javascript = {
      enable = mkDefault true;
    };

    git-hooks.hooks = {
      biome = mkIf cfg.biome.enable {
        enable = mkDefault true;
        types_or = mkDefault [
          "javascript"
        ];
      };
    };

    treefmt.config.programs = {
      biome = mkIf cfg.biome.enable {
        enable = mkDefault cfg.biome.enable;
        settings = {
          javascript = {
            formatter = {
              indentStyle = mkDefault "space";
            };
          };
        };
        includes = mkDefault [
          "*.js"
          "*.jsx"
          "*.mjs"
        ];
      };
    };
  };
}
