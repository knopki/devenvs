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

  cfg = config.knopki.nixos;
in
{
  options.knopki.nixos = {
    enable = mkEnableOption "Enable NixOS tools";

    nh = {
      enable = mkEnableOption "Enable nh tool" // {
        default = true;
      };
      package = mkPackageOption pkgs "nh" { };
    };
  };

  config = mkIf cfg.enable {
    knopki = {
      git.enable = mkDefault true;
      json.enable = mkDefault true;
      nix.enable = mkDefault true;
      toml.enable = mkDefault true;
      yaml.enable = mkDefault true;
    };

    packages = optional cfg.nh.enable cfg.nh.package;

    knopki.menu.commands = map (cmd: cmd // { category = "nixos"; }) (
      optional cfg.nh.enable {
        inherit (cfg.nh) package;
      }
    );
  };
}
