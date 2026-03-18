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
  inherit (lib.lists) optional optionals;
  inherit (myLib) commandsFromConfigs mkOverrideDefault packagesFromConfigs;

  cfg = config.knopki.containers;
in
{
  options.knopki.containers = {
    enable = mkEnableOption "Enable containers tools";

    hadolint = {
      enable = mkEnableOption "Enable hadolint Dockerfile linter";
      package = mkPackageOption pkgs "hadolint" { };
    };

    lazydocker = {
      enable = mkEnableOption "Enable lazydocker";
      package = mkPackageOption pkgs "lazydocker" { };
    };

    docker-compose-format = {
      enable = mkEnableOption "Enable docker compose formatting";
    };

    docker-compose-ls = {
      enable = mkEnableOption "Enable docker compose language server";
      package = mkPackageOption pkgs "docker-compose-language-service" { };
    };

    dockerfile-format = {
      enable = mkEnableOption "Enable dockerfile formatting";
    };

    dockerfile-ls = {
      enable = mkEnableOption "Enable dockerfile language server";
      package = mkPackageOption pkgs "dockerfile-language-server" { };
    };
  };

  config = mkIf cfg.enable {

    packages = packagesFromConfigs [
      cfg.hadolint
      cfg.lazydocker
      cfg.docker-compose-ls
      cfg.dockerfile-ls
    ];

    git-hooks.hooks = {
      hadolint = {
        enable = mkDefault cfg.hadolint.enable;
        package = mkOverrideDefault cfg.hadolint.package;
      };
    };

    treefmt.config.programs = {
      dprint = {
        enable = mkDefault (cfg.dockerfile-format.enable || cfg.docker-compose-format.enable);
        includes =
          optionals cfg.dockerfile-format.enable [
            "Dockerfile"
            "Containerfile"
          ]
          ++ optionals cfg.docker-compose-format.enable [
            "compose.yaml"
            "compose.yml"
            "docker-compose.yaml"
            "docker-compose.yml"
          ];
        settings.plugins = pkgs.dprint-plugins.getPluginList (
          ps:
          optional cfg.dockerfile-format.enable ps.dprint-plugin-dockerfile
          ++ optional cfg.docker-compose-format.enable ps.g-plane-pretty_yaml
        );
      };
    };

    knopki.menu.commands = commandsFromConfigs { category = "containers"; } [
      cfg.hadolint
      cfg.lazydocker
      cfg.docker-compose-ls
      cfg.dockerfile-ls
    ];
  };
}
