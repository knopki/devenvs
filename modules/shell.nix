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
  inherit (myLib) commandsFromConfigs mkOverrideDefault packagesFromConfigs;

  cfg = config.knopki.shell;
in
{

  options.knopki.shell = {
    enable = mkEnableOption "Enable shell support";

    lsp = {
      enable = mkEnableOption "Enable LSP";
      package = mkPackageOption pkgs "bash-language-server" { };
    };

    fd = {
      enable = mkEnableOption "Enable fd tool";
      package = mkPackageOption pkgs "fd" { };
    };

    ripgrep = {
      enable = mkEnableOption "Enable ripgrep tool";
      package = mkPackageOption pkgs "ripgrep" { };
    };

    shellcheck = {
      enable = mkEnableOption "Enable shellcheck linter";
      package = mkPackageOption pkgs "shellcheck" { };
    };

    shfmt = {
      enable = mkEnableOption "Enable shfmt formatting";
      package = mkPackageOption pkgs "shfmt" { };
      indent = mkOption {
        type = with lib.types; nullOr int;
        default = 2;
        description = ''
          Sets the number of spaces to be used in indentation. Uses tabs if set to
          zero.
        '';
      };
      simplify = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = ''
          Enables the `-s` (`--simplify`) flag, which simplifies code where possible.
        '';
      };
    };
  };

  config = mkIf cfg.enable {
    packages = packagesFromConfigs [
      cfg.lsp
      cfg.fd
      cfg.ripgrep
      cfg.shfmt
      cfg.shellcheck
    ];

    git-hooks.hooks = {
      shellcheck = {
        enable = mkDefault cfg.shellcheck.enable;
        package = mkOverrideDefault cfg.shellcheck.package;
      };
      shfmt = {
        enable = mkDefault (cfg.shfmt.enable && !config.treefmt.enable);
        package = mkOverrideDefault cfg.shfmt.package;
        settings = {
          indent = mkOverrideDefault cfg.shfmt.indent;
          simplify = mkOverrideDefault cfg.shfmt.simplify;
        };
      };
    };

    treefmt.config.programs = {
      shfmt = {
        enable = mkDefault cfg.shfmt.enable;
        package = mkOverrideDefault cfg.shfmt.package;
        indent_size = mkOverrideDefault cfg.shfmt.indent;
        simplify = mkOverrideDefault cfg.shfmt.simplify;
      };
    };

    knopki.menu.commands = commandsFromConfigs { category = "shell"; } [
      cfg.lsp
      cfg.fd
      cfg.ripgrep
      cfg.shellcheck
      cfg.shfmt
    ];
  };
}
