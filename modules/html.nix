{
  config,
  lib,
  ...
}:
let
  inherit (lib.modules) mkDefault mkIf;
  inherit (lib.options) mkEnableOption;

  cfg = config.knopki.html;
in
{
  options.knopki.html = {
    enable = mkEnableOption "Enable html support";

    biome.enable = mkEnableOption "Enable biome";
  };

  config = mkIf cfg.enable {
    git-hooks.hooks = {
      biome = mkIf cfg.biome.enable {
        enable = mkDefault true;
        types_or = mkDefault [
          "html"
          "xhtml"
          "svelte"
        ];
      };
    };

    treefmt.config.programs = {
      biome = mkIf cfg.biome.enable {
        enable = mkDefault cfg.biome.enable;
        includes = mkDefault [
          "*.html"
          "*.htm"
          "*.svelte"
        ];
      };
    };
  };
}
