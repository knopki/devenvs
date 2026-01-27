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
  inherit (lib.meta) getExe;

  cfg = config.knopki.git;
in
{
  options.knopki.git = {
    enable = mkEnableOption "Enable Git";
    package = mkPackageOption pkgs "git" { };

    gitleaks = {
      enable = mkEnableOption "Enable gitleaks" // {
        default = true;
      };
      package = mkPackageOption pkgs "gitleaks" { };
    };

    lazygit = {
      enable = mkEnableOption "Enable lazygit" // {
        default = true;
      };
      package = mkPackageOption pkgs "lazygit" { };
    };
  };

  config = mkIf cfg.enable {
    packages = [
      cfg.package
    ]
    ++ optional cfg.gitleaks.enable cfg.gitleaks.package
    ++ optional cfg.lazygit.enable cfg.lazygit.package;

    difftastic.enable = mkDefault true;

    delta.enable = mkDefault (!config.difftastic.enable);

    git-hooks.hooks = {
      check-added-large-files.enable = mkDefault true;
      check-case-conflicts.enable = mkDefault true;
      check-executables-have-shebangs.enable = mkDefault true;
      check-merge-conflicts.enable = mkDefault true;
      check-shebang-scripts-are-executable.enable = mkDefault true;
      check-symlinks.enable = mkDefault true;
      check-vcs-permalinks.enable = mkDefault true;
      commitizen.enable = mkDefault true;
      detect-private-keys.enable = mkDefault true;
      end-of-file-fixer.enable = mkDefault true;
      fix-byte-order-marker.enable = mkDefault true;
      gitlint = mkDefault true;
      mixed-line-endings.enable = mkDefault true;
      no-commit-to-branch = {
        enable = mkDefault true;
        settings.branch = mkDefault [
          "master"
          "main"
        ];
      };
      pre-commit-hook-ensure-sops.enable = mkDefault true;
      gitleaks = mkIf cfg.gitleaks.enable {
        inherit (cfg.gitleaks) package;
        enable = mkDefault true;
        pass_filenames = false;
        entry = "${getExe cfg.gitleaks.package} git";
        args = [
          "--staged"
          "--redact"
        ];
      };
    };

    knopki.menu.commands = map (cmd: cmd // { category = "git"; }) (
      [
        {
          package = pkgs.git;
        }
      ]
      ++ optional cfg.gitleaks.enable {
        inherit (cfg.gitleaks) package;
      }
      ++ optional cfg.lazygit.enable {
        inherit (cfg.lazygit) package;
      }
    );
  };
}
