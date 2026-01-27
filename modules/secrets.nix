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

  cfg = config.knopki.secrets;
in
{
  options.knopki.secrets = {
    enable = mkEnableOption "Enable secret management tools" // {
      default = cfg.age.enable || cfg.libsecret.enable || cfg.sops.enable;
    };

    age = {
      enable = mkEnableOption "Enable age tool" // {
        default = cfg.sops.enable;
      };
      package = mkPackageOption pkgs "age" { };
    };

    libsecret = {
      enable = mkEnableOption "Enable libsecret tools (Linux)" // {
        default = pkgs.stdenv.isLinux;
      };
      package = mkPackageOption pkgs "libsecret" { };
    };

    sops = {
      enable = mkEnableOption "Enable SOPS integration";
      package = mkPackageOption pkgs "sops" { };
    };
  };

  config = mkIf cfg.enable {
    packages =
      optional cfg.age.enable cfg.age.package
      ++ optional cfg.libsecret.enable cfg.libsecret.package
      ++ optional cfg.sops.enable cfg.sops.package;

    git-hooks.hooks = {
      pre-commit-hook-ensure-sops = mkDefault cfg.sops.enable;
    };

    knopki.menu.commands = map (cmd: cmd // { category = "secrets"; }) (
      optional cfg.age.enable {
        inherit (cfg.age) package;
      }
      ++ optional cfg.libsecret.enable {
        inherit (cfg.libsecret) package;
      }
      ++ optional cfg.sops.enable {
        inherit (cfg.sops) package;
      }
    );
  };
}
