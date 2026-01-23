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

    nix-inspect = {
      enable = mkEnableOption "Enable nix-inspect tool" // {
        default = true;
      };
      package = mkPackageOption pkgs "nix-inspect" { };
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

    packages =
      optional cfg.nh.enable cfg.nh.package ++ optional cfg.nix-inspect.enable cfg.nix-inspect.package;

    knopki.menu.commands = map (cmd: cmd // { category = "nixos"; }) (
      optional cfg.nh.enable {
        inherit (cfg.nh) package;
      }
      ++ optional cfg.nix-inspect.enable {
        inherit (cfg.nix-inspect) package;
      }
    );
  };
}
