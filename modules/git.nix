{
  config,
  lib,
  pkgs,
  myLib,
  ...
}:
let
  inherit (lib.modules) mkDefault mkAliasOptionModule mkIf;
  inherit (lib.options) mkEnableOption mkPackageOption;
  inherit (lib.meta) getExe;
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
      check-added-large-files.enable = mkDefault cfg.withGitHooks;
      check-case-conflicts.enable = mkDefault cfg.withGitHooks;
      check-executables-have-shebangs.enable = mkDefault cfg.withGitHooks;
      check-merge-conflicts.enable = mkDefault cfg.withGitHooks;
      check-shebang-scripts-are-executable.enable = mkDefault cfg.withGitHooks;
      check-symlinks.enable = mkDefault cfg.withGitHooks;
      check-vcs-permalinks.enable = mkDefault cfg.withGitHooks;
      commitizen.enable = mkDefault cfg.withGitHooks;
      detect-private-keys.enable = mkDefault cfg.withGitHooks;
      end-of-file-fixer.enable = mkDefault cfg.withGitHooks;
      fix-byte-order-marker.enable = mkDefault cfg.withGitHooks;
      gitlint = mkDefault cfg.withGitHooks;
      mixed-line-endings.enable = mkDefault cfg.withGitHooks;
      no-commit-to-branch = {
        enable = mkDefault cfg.withGitHooks;
        settings.branch = mkDefault [
          "master"
          "main"
        ];
      };
      gitleaks = mkIf cfg.gitleaks.enable {
        inherit (cfg.gitleaks) package;
        enable = mkDefault cfg.withGitHooks;
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
