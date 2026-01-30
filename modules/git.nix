{
  config,
  lib,
  pkgs,
  myLib,
  ...
}:
let
  inherit (lib.modules) mkAliasOptionModule mkIf;
  inherit (lib.options) mkEnableOption mkPackageOption;
  inherit (lib.meta) getExe;
  inherit (config.lib) mkOverrideDefault;
  inherit (myLib) commandsFromConfigs packagesFromConfigs;

  cfg = config.knopki.git;
in
{
  imports = [
    (mkAliasOptionModule [ "knopki" "git" "delta" ] [ "delta" ])
    (mkAliasOptionModule [ "knopki" "git" "difftastic" ] [ "difftastic" ])
  ];

  options.knopki.git = {
    enable = mkEnableOption "Enable Git";
    package = mkPackageOption pkgs "gitMinimal" { };
    withGitHooks = mkEnableOption "Enable standard git hooks";

    gitleaks = {
      enable = mkEnableOption "Enable gitleaks";
      package = mkPackageOption pkgs "gitleaks" { };
    };

    lazygit = {
      enable = mkEnableOption "Enable lazygit";
      package = mkPackageOption pkgs "lazygit" { };
    };
  };

  config = mkIf cfg.enable {
    packages = [
      cfg.package
    ]
    ++ packagesFromConfigs [
      cfg.gitleaks
      cfg.lazygit
    ];

    git-hooks.hooks = {
      check-added-large-files.enable = mkOverrideDefault cfg.withGitHooks;
      check-case-conflicts.enable = mkOverrideDefault cfg.withGitHooks;
      check-executables-have-shebangs.enable = mkOverrideDefault cfg.withGitHooks;
      check-merge-conflicts.enable = mkOverrideDefault cfg.withGitHooks;
      check-shebang-scripts-are-executable.enable = mkOverrideDefault cfg.withGitHooks;
      check-symlinks.enable = mkOverrideDefault cfg.withGitHooks;
      check-vcs-permalinks.enable = mkOverrideDefault cfg.withGitHooks;
      commitizen.enable = mkOverrideDefault cfg.withGitHooks;
      detect-private-keys.enable = mkOverrideDefault cfg.withGitHooks;
      end-of-file-fixer.enable = mkOverrideDefault cfg.withGitHooks;
      fix-byte-order-marker.enable = mkOverrideDefault cfg.withGitHooks;
      gitlint = mkOverrideDefault cfg.withGitHooks;
      mixed-line-endings.enable = mkOverrideDefault cfg.withGitHooks;
      no-commit-to-branch = {
        enable = mkOverrideDefault cfg.withGitHooks;
        settings.branch = mkOverrideDefault [
          "master"
          "main"
        ];
      };
      pre-commit-hook-ensure-sops.enable = mkOverrideDefault cfg.withGitHooks;
      gitleaks = mkIf cfg.gitleaks.enable {
        inherit (cfg.gitleaks) package;
        enable = mkOverrideDefault cfg.withGitHooks;
        pass_filenames = false;
        entry = "${getExe cfg.gitleaks.package} git";
        args = [
          "--staged"
          "--redact"
        ];
      };
    };

    knopki.menu.commands = commandsFromConfigs { category = "git"; } [
      cfg
      cfg.gitleaks
      cfg.lazygit
    ];
  };
}
