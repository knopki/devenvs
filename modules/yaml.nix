{
  config,
  lib,
  ...
}:
let
  inherit (lib.modules) mkDefault mkIf;
  inherit (lib.options) mkEnableOption mkPackageOption;
  inherit (lib.lists) optional;

  cfg = config.knopki.yaml;
in
{
  options.knopki.yaml = {
    enable = mkEnableOption "Enable yaml support";

    yamllint = {
      enable = mkEnableOption "Enable yamllint" // {
        default = true;
      };
      package = mkPackageOption config.git-hooks.hooks.yamllint "package" { };
    };

    yamlfmt = {
      enable = mkEnableOption "Enable yamlfmt" // {
        default = true;
      };
      package = mkPackageOption config.git-hooks.hooks.yamlfmt "package" { };
    };
  };

  config = mkIf cfg.enable {
    packages =
      optional cfg.yamllint.enable cfg.yamllint.package
      ++ optional cfg.yamlfmt.enable cfg.yamlfmt.package;

    git-hooks.hooks = {
      check-yaml.enable = mkDefault true;
      yamllint.enable = mkDefault cfg.yamllint.enable;
      yamlfmt.enable = mkDefault cfg.yamlfmt.enable;
    };

    treefmt.config.programs = {
      yamlfmt.enable = mkDefault cfg.yamlfmt.enable;
    };

    knopki.menu.commands = map (cmd: cmd // { category = "yaml"; }) (
      optional cfg.yamlfmt.enable { inherit (cfg.yamlfmt) package; }
      ++ optional cfg.yamllint.enable { inherit (cfg.yamllint) package; }
    );
  };
}
