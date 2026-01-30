{
  config,
  lib,
  pkgs,
  myLib,
  ...
}:
let
  inherit (lib.modules) mkDefault mkIf;
  inherit (lib.options) mkEnableOption mkOption mkPackageOption;
  inherit (lib.lists) optional;
  inherit (config.lib) mkOverrideDefault;
  inherit (myLib) commandsFromConfigs packagesFromConfigs;

  cfg = config.knopki.nix;
in
{
  options.knopki.nix = {
    enable = mkEnableOption "Enable nix support";
    package = mkOption {
      type = with lib.types; nullOr package;
      default = null;
      description = "The Nix package to install (if any)";
    };

    lsp = {
      enable = mkEnableOption "Enable LSP server";
      package = mkPackageOption pkgs "nixd" { };
    };

    nixfmt = {
      enable = mkEnableOption "Enable nixfmt";
      package = mkPackageOption pkgs "nixfmt-rfc-style" { };
    };

    flake-checker = {
      enable = mkEnableOption "Enable flake-checker";
      package = mkPackageOption pkgs "flake-checker" { };
    };

    deadnix = {
      enable = mkEnableOption "Enable deadnix";
      package = mkPackageOption pkgs "deadnix" { };
    };

    statix = {
      enable = mkEnableOption "Enable statix";
      package = mkPackageOption pkgs "statix" { };
    };

    cachix = {
      enable = mkEnableOption "Enable cachix" // {
        default = config.cachix.enable;
      };
      package = mkPackageOption config.cachix "package" { };
    };

    dix = {
      enable = mkEnableOption "Enable dix diff tool";
      package = mkPackageOption pkgs "dix" { };
    };
  };

  config = mkIf cfg.enable {
    packages = packagesFromConfigs [
      cfg.lsp
      cfg.cachix
      cfg.nixfmt
      cfg.flake-checker
      cfg.deadnix
      cfg.statix
      cfg.dix
    ] ++ optional (cfg.package != null) cfg.package;

    git-hooks.hooks = {
      deadnix = {
        enable = mkDefault cfg.deadnix.enable;
        package = mkOverrideDefault cfg.deadnix.package;
      };
      flake-checker = {
        enable = mkDefault cfg.flake-checker.enable;
        package = mkOverrideDefault cfg.flake-checker.package;
      };
      nixfmt-rfc-style = {
        enable = mkDefault cfg.nixfmt.enable;
        package = mkOverrideDefault cfg.nixfmt.package;
      };
      statix = {
        enable = mkDefault cfg.statix.enable;
        package = mkOverrideDefault cfg.statix.package;
      };
    };

    treefmt.config.programs = {
      deadnix = {
        enable = mkDefault cfg.deadnix.enable;
        package = mkOverrideDefault cfg.deadnix.package;
      };
      nixfmt = {
        enable = mkDefault cfg.nixfmt.enable;
        package = mkOverrideDefault cfg.nixfmt.package;
      };
      statix = {
        enable = mkDefault cfg.statix.enable;
        package = mkOverrideDefault cfg.statix.package;
      };
    };

    knopki.menu.commands = commandsFromConfigs { category = "nix"; } [
      cfg.lsp
      cfg.cachix
      cfg.nixfmt
      cfg.flake-checker
      cfg.deadnix
      cfg.statix
      cfg.dix
    ];
  };
}
