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

  cfg = config.knopki.shell;
in
{
  options.knopki.shell = {
    enable = mkEnableOption "Enable shell support";

    ripgrep = {
      enable = mkEnableOption "Enable ripgrep tool" // {
        default = true;
      };
      package = mkPackageOption pkgs "ripgrep" { };
    };

    shellcheck = {
      enable = mkEnableOption "Enable shellcheck linter" // {
        default = true;
      };
      package = mkPackageOption config.git-hooks.hooks.shellcheck "package" { };
    };

    shfmt = {
      enable = mkEnableOption "Enable shfmt formatting" // {
        default = true;
      };
      package = mkPackageOption config.git-hooks.hooks.shfmt "package" { };
    };
  };

  config = mkIf cfg.enable {
    packages = concatMap (x: optional x.enable x.package) (
      with cfg;
      [
        ripgrep
        shfmt
        shellcheck
      ]
    );

    languages.shell = {
      enable = mkDefault true;
      lsp.enable = mkDefault true; # bash-language-server
    };

    git-hooks.hooks = {
      shellcheck.enable = mkDefault cfg.shellcheck.enable;
      shfmt.enable = mkDefault cfg.shfmt.enable;
    };

    treefmt.config.programs = {
      shfmt.enable = mkDefault cfg.shfmt.enable;
    };

    knopki.menu.commands = map (cmd: cmd // { category = "shell"; }) (
      optional config.languages.shell.lsp.enable {
        inherit (config.languages.shell.lsp) package;
      }
      ++ optional cfg.shellcheck.enable {
        inherit (cfg.shellcheck) package;
      }
      ++ optional cfg.shfmt.enable {
        inherit (cfg.shfmt) package;
      }
    );
  };
}
