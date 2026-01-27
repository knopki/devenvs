{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib.modules) mkDefault mkIf;
  inherit (lib.options) mkEnableOption mkPackageOption;
  inherit (lib.lists) concatMap optional;

  cfg = config.knopki.markdown;
in
{
  options.knopki.markdown = {
    enable = mkEnableOption "Enable markdown support";

    glow = {
      enable = mkEnableOption "Enable glow viewer" // {
        default = true;
      };
      package = mkPackageOption pkgs "glow" { };
    };

    lychee = {
      enable = mkEnableOption "Enable lychee linter" // {
        default = true;
      };
      package = mkPackageOption config.git-hooks.hooks.lychee "package" { };
    };

    marksman = {
      enable = mkEnableOption "Enable marksman" // {
        default = true;
      };
      package = mkPackageOption pkgs "marksman" { };
    };

    markdownlint = {
      enable = mkEnableOption "Enable markdownlint" // {
        default = true;
      };
      package = mkPackageOption config.git-hooks.hooks.markdownlint "package" { };
    };
  };

  config = mkIf cfg.enable {
    packages = concatMap (x: optional x.enable x.package) (
      with cfg;
      [
        glow
        lychee
        marksman
        markdownlint
      ]
    );

    git-hooks.hooks = {
      lychee.enable = mkDefault cfg.lychee.enable;
      denofmt.enable = mkDefault true;
      markdownlint.enable = mkDefault cfg.markdownlint.enable;
    };

    treefmt.config.programs = {
      deno.enable = mkDefault true;
    };

    knopki.menu.commands = map (cmd: cmd // { category = "markdown"; }) (
      optional config.git-hooks.hooks.denofmt.enable {
        inherit (config.git-hooks.hooks.denofmt) package;
        name = "deno fmt";
      }
      ++ optional cfg.glow.enable {
        inherit (cfg.glow) package;
      }
      ++ optional cfg.lychee.enable {
        inherit (cfg.lychee) package;
      }
      ++ optional cfg.marksman.enable {
        inherit (cfg.marksman) package;
      }
      ++ optional cfg.markdownlint.enable {
        inherit (cfg.markdownlint) package;
      }
    );
  };
}
