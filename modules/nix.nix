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
      package = mkPackageOption config.git-hooks.hooks.nixfmt-rfc-style "package" { };
    };

    flake-checker = {
      enable = mkEnableOption "Enable flake-checker" // {
        default = true;
      };
      package = mkPackageOption config.git-hooks.hooks.flake-checker "package" { };
    };

    deadnix = {
      enable = mkEnableOption "Enable deadnix" // {
        default = true;
      };
      package = mkPackageOption config.git-hooks.hooks.deadnix "package" { };
    };

    statix = {
      enable = mkEnableOption "Enable statix" // {
        default = true;
      };
      package = mkPackageOption config.git-hooks.hooks.statix "package" { };
    };
  };

  config = mkIf cfg.enable {
    packages = [
      cfg.package
    ]
    ++ optional cfg.nixfmt.enable cfg.nixfmt.package
    ++ optional cfg.flake-checker.enable cfg.flake-checker.package
    ++ optional cfg.deadnix.enable cfg.deadnix.package
    ++ optional cfg.statix.enable cfg.statix.package;

    languages.nix = {
      enable = mkDefault true;
      lsp.enable = mkDefault true; # nixd
    };

    git-hooks.hooks = {
      deadnix.enable = mkDefault cfg.deadnix.enable;
      flake-checker.enable = mkDefault cfg.flake-checker.enable;
      nixfmt-rfc-style.enable = mkDefault cfg.nixfmt.enable;
      statix.enable = mkDefault cfg.statix.enable;
    };

    treefmt.config.programs = {
      deadnix.enable = mkDefault cfg.deadnix.enable;
      nixfmt.enable = mkDefault cfg.nixfmt.enable;
      statix.enable = mkDefault cfg.statix.enable;
    };

    knopki.menu.commands = map (cmd: cmd // { category = "nix"; }) (
      [
        {
          inherit (cfg) package;
        }
      ]
      ++ optional cfg.nixfmt.enable {
        inherit (cfg.nixfmt) package;
      }
      ++ optional cfg.flake-checker.enable {
        inherit (cfg.flake-checker) package;
      }
      ++ optional cfg.deadnix.enable {
        inherit (cfg.deadnix) package;
      }
      ++ optional cfg.statix.enable {
        inherit (cfg.statix) package;
      }
      ++ optional config.languages.nix.lsp.enable {
        inherit (config.languages.nix.lsp) package;
      }
    );
  };
}
