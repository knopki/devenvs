{
  config,
  lib,
  pkgs,
  ...
}:let
  inherit (lib.modules) mkDefault mkIf;
  inherit (lib.options) mkEnableOption mkPackageOption;
  inherit (lib.lists) optional;

  cfg = config.knopki.git;
in
{
  options.knopki.git = {
    enable = mkEnableOption "Enable Git";
    package = mkPackageOption pkgs "git" { };

    lazygit = {
      enable = mkEnableOption "Enable lazygit" // { default = true; };
      package = mkPackageOption pkgs "lazygit" {};
    };
  };

  config = mkIf cfg.enable {
    packages = [
      cfg.package
      pkgs.commitizen
    ] ++ optional cfg.lazygit.enable cfg.lazygit.package;

    difftastic.enable = mkDefault true;

    delta.enable = mkDefault true;

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
      mixed-line-endings.enable = mkDefault true;
      no-commit-to-branch = {
        enable = mkDefault true;
        settings.branch = mkDefault [ "master" "main" ];
      };
      pre-commit-hook-ensure-sops.enable = mkDefault true;
    };
  };
}
