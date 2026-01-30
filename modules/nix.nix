{
  config,
  lib,
  pkgs,
  myLib,
  ...
}:
let
  inherit (lib.modules) mkIf;
  inherit (lib.options) mkEnableOption mkOption mkPackageOption;
  inherit (config.lib) mkOverrideDefault;
  inherit (myLib) commandsFromConfigs packagesFromConfigs;

  cfg = config.knopki.nix;
in
{
  options.knopki.nix = {
    enable = mkEnableOption "Enable nix support";
    package = mkOption {
      type = lib.types.package;
      default = pkgs.nix;
      description = "The Nix package to use";
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
      cfg
      cfg.lsp
      cfg.cachix
      cfg.nixfmt
      cfg.flake-checker
      cfg.deadnix
      cfg.statix
      cfg.dix
    ];

    git-hooks.hooks = {
      deadnix = {
        enable = mkOverrideDefault cfg.deadnix.enable;
        package = mkOverrideDefault cfg.deadnix.package;
      };
      flake-checker = {
        enable = mkOverrideDefault cfg.flake-checker.enable;
        package = mkOverrideDefault cfg.flake-checker.package;
      };
      nixfmt-rfc-style = {
        enable = mkOverrideDefault cfg.nixfmt.enable;
        package = mkOverrideDefault cfg.nixfmt.package;
      };
      statix = {
        enable = mkOverrideDefault cfg.statix.enable;
        package = mkOverrideDefault cfg.statix.package;
      };
    };

    treefmt.config.programs = {
      deadnix = {
        enable = mkOverrideDefault cfg.deadnix.enable;
        package = mkOverrideDefault cfg.deadnix.package;
      };
      nixfmt = {
        enable = mkOverrideDefault cfg.nixfmt.enable;
        package = mkOverrideDefault cfg.nixfmt.package;
      };
      statix = {
        enable = mkOverrideDefault cfg.statix.enable;
        package = mkOverrideDefault cfg.statix.package;
      };
    };

    knopki.menu.commands = commandsFromConfigs { category = "nix"; } [
      cfg
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
