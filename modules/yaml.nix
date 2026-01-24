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
  };

  config = mkIf cfg.enable {
    packages =
      optional cfg.yamllint.enable cfg.yamllint.package
      ++ optional config.git-hooks.hooks.denofmt.enable config.git-hooks.hooks.denofmt.package;

    git-hooks.hooks = {
      check-yaml.enable = mkDefault true;
      denofmt.enable = mkDefault true;
      yamllint.enable = mkDefault cfg.yamllint.enable;
    };

    treefmt.config.programs = {
      deno.enable = mkDefault true;
    };

    knopki.menu.commands = map (cmd: cmd // { category = "yaml"; }) (
      optional config.git-hooks.hooks.denofmt.enable {
        inherit (config.git-hooks.hooks.denofmt) package;
        name = "deno fmt";
      }
      ++ optional cfg.yamllint.enable { inherit (cfg.yamllint) package; }
    );
  };
}
