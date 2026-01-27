{
  config,
  lib,
  pkgs,
  myLib,
  ...
}:
let
  inherit (lib.modules) mkDefault mkIf;
  inherit (lib.options) mkEnableOption mkPackageOption;
  inherit (myLib) commandsFromConfigs packagesFromConfigs;

  cfg = config.knopki.shell;
in
{
  options.knopki.shell = {
    enable = mkEnableOption "Enable shell support";

    fd = {
      enable = mkEnableOption "Enable fd tool" // {
        default = true;
      };
      package = mkPackageOption pkgs "fd" { };
    };

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
    packages = packagesFromConfigs [
      cfg.fd
      cfg.ripgrep
      cfg.shfmt
      cfg.shellcheck
    ];

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

    knopki.menu.commands = commandsFromConfigs { category = "shell"; } [
      config.languages.shell.lsp
      cfg.fd
      cfg.ripgrep
      cfg.shellcheck
      cfg.shfmt
    ];
  };
}
