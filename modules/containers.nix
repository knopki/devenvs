{
  config,
  lib,
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
      enable = mkEnableOption "Enable hadolint Dockerfile linter" // {
        default = true;
      };
      package = mkPackageOption config.git-hooks.hooks.hadolint "package" { };
    };
  };

  config = mkIf cfg.enable {
    packages = optional cfg.hadolint.enable cfg.hadolint.package;

    git-hooks.hooks = {
      hadolint.enable = mkDefault cfg.hadolint.enable;
    };

    knopki.menu.commands = map (cmd: cmd // { category = "containers"; }) (
      optional cfg.hadolint.enable {
        inherit (cfg.hadolint) package;
      }
    );
  };
}
