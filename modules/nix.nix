{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib.modules) mkDefault mkIf;
  inherit (lib.options) mkEnableOption mkOption mkPackageOption;
  inherit (lib.lists) optional;

  cfg = config.knopki.nix;
in
{
  options.knopki.nix = {
    enable = mkEnableOption "Enable nix support";
    package = mkOption {
      type = lib.types.package;
      default = pkgs.nixVersions.latest;
      description = "The Nix package to use";
    };

    nixfmt = {
      enable = mkEnableOption "Enable nixfmt" // {
        default = true;
      };
      package = mkPackageOption pkgs "nixfmt" { };
    };

    flake-checker = {
      enable = mkEnableOption "Enable flake-checker" // {
        default = true;
      };
      package = mkPackageOption pkgs "flake-checker" { };
    };
  };

  config = mkIf cfg.enable {
    packages = [
      cfg.package
    ]
    ++ optional cfg.nixfmt.enable cfg.nixfmt.package
    ++ optional cfg.flake-checker.enable cfg.flake-checker.package;

    languages.nix = {
      enable = mkDefault true;
      lsp.enable = mkDefault true; # nixd
    };

    git-hooks.hooks = {
      flake-checker = {
        enable = mkDefault cfg.flake-checker.enable;
        package = cfg.flake-checker.package;
      };
      nixfmt-rfc-style = {
        enable = mkDefault cfg.nixfmt.enable;
        package = cfg.nixfmt.package;
      };
    };

    treefmt.config.programs = {
      nixfmt.enable = mkDefault cfg.nixfmt.enable;
    };
  };
}
