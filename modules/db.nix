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
  inherit (lib.lists) optional optionals;
  inherit (config.lib) mkOverrideDefault;
  inherit (myLib) commandsFromConfigs packagesFromConfigs;

  cfg = config.knopki.db;
in
{
  options.knopki.db = {
    enable = mkEnableOption "Enable containers tools" // {
      default = cfg.sqlite.enable || cfg.postgres.enable;
    };

    sqlite = {
      enable = mkEnableOption "Enable sqlite";
      package = mkPackageOption pkgs "sqlite" { };
    };

    postgres = {
      enable = mkEnableOption "Enable postgresql" // {
        default = cfg.postgres.service.enable;
      };
      package = mkPackageOption config.services.postgres "package" { };
      service = {
        enable = mkEnableOption "Enable postgresql service";
      };
    };

    dblab = {
      enable = mkEnableOption "Enable dblab database client";
      package = mkPackageOption pkgs "dblab" { };
    };

    harlequin = {
      enable = mkEnableOption "Enable harlequin database IDE";
      package = mkPackageOption pkgs "harlequin" { };
    };

    lazysql = {
      enable = mkEnableOption "Enable lazysql database client";
      package = mkPackageOption pkgs "lazysql" { };
    };

    rainfrog = {
      enable = mkEnableOption "Enable rainfrog postgres client";
      package = mkPackageOption pkgs "rainfrog" { };
    };

    sqruff = {
      enable = mkEnableOption "Enable sqruff formatter";
      package = mkPackageOption pkgs "sqruff" { };
    };
  };

  config = mkIf cfg.enable {
    packages = packagesFromConfigs [
      cfg.sqlite
      cfg.postgres
      cfg.dblab
      cfg.harlequin
      cfg.lazysql
      cfg.rainfrog
      cfg.sqruff
    ];

    treefmt.config.programs = {
      sqruff = {
        enable = mkOverrideDefault cfg.sqruff.enable;
        package = mkOverrideDefault cfg.sqruff.package;
      };
    };

    knopki.menu.commands =
      optionals cfg.postgres.enable (
        map
          (name: {
            inherit name;
            inherit (cfg.postgres) package;
            category = "db";
          })
          [
            "createdb"
            "createuser"
            "dropdb"
            "dropuser"
            "initdb"
            "psql"
            "pg_*"
          ]
      )
      ++ commandsFromConfigs { category = "db"; } [
        cfg.sqlite
        cfg.harlequin
        cfg.lazysql
        cfg.rainfrog
        cfg.sqruff
      ]
      ++ optional cfg.dblab.enable {
        inherit (cfg.dblab) package;
        name = "dblab";
      };

    services.postgres.enable = mkOverrideDefault cfg.postgres.service.enable;

    tasks = {
      "services:postgres:reset" = mkIf cfg.postgres.service.enable {
        description = "Delete PostgreSQL data";
        exec = ''
          echo "Deleting PostgreSQL data in ''${PGDATA}"
          [[ -e "''${PGDATA}" ]] && rm -r "''${PGDATA}"
        '';
      };
    };
  };
}
