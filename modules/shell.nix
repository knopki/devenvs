{
  config,
  lib,
  pkgs,
  myLib,
  ...
}:
let
  inherit (lib.modules) mkIf;
  inherit (lib.options) mkEnableOption mkPackageOption;
  inherit (config.lib) mkOverrideDefault;
  inherit (myLib) commandsFromConfigs packagesFromConfigs;

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
        enable = mkOverrideDefault cfg.shellcheck.enable;
        package = mkOverrideDefault cfg.shellcheck.package;
      };
      shfmt = {
        enable = mkOverrideDefault cfg.shfmt.enable;
        package = mkOverrideDefault cfg.shfmt.package;
      };
    };

    treefmt.config.programs = {
      shfmt = {
        enable = mkOverrideDefault cfg.shfmt.enable;
        package = mkOverrideDefault cfg.shfmt.package;
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
