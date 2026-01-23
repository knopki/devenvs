{
  config,
  lib,
  ...
}:
let
  inherit (lib.modules) mkDefault mkIf;
  inherit (lib.options) mkEnableOption;

  cfg = config.knopki.nixos;
in
{
  options.knopki.nixos = {
    enable = mkEnableOption "Enable NixOS tools";
  };

  config = mkIf cfg.enable {
    knopki = {

      git.enable = mkDefault true;
      json.enable = mkDefault true;
      nix.enable = mkDefault true;
      toml.enable = mkDefault true;
      yaml.enable = mkDefault true;
    };
  };
}
