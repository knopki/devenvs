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

  cfg = config.knopki.containers;
in
{
  options.knopki.containers = {
    enable = mkEnableOption "Enable containers tools";

    hadolint = {
      enable = mkEnableOption "Enable hadolint Dockerfile linter";
      package = mkPackageOption config.git-hooks.hooks.hadolint "package" { };
    };

    lazydocker = {
      enable = mkEnableOption "Enable lazydocker";
      package = mkPackageOption pkgs "lazydocker" { };
    };
  };

  config = mkIf cfg.enable {
    packages =
      optional cfg.hadolint.enable cfg.hadolint.package
      ++ optional cfg.lazydocker.enable cfg.lazydocker.package;

    git-hooks.hooks = {
      hadolint.enable = mkDefault cfg.hadolint.enable;
    };

    knopki.menu.commands = map (cmd: cmd // { category = "containers"; }) (
      optional cfg.hadolint.enable {
        inherit (cfg.hadolint) package;
      }
      ++ optional cfg.lazydocker.enable {
        inherit (cfg.lazydocker) package;
      }
    );
  };
}
