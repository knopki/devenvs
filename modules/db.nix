{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib.modules) mkDefault mkIf;
  inherit (lib.options) mkEnableOption mkPackageOption;
  inherit (lib.lists) optional optionals;

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
      enable = mkEnableOption "Enable postgresql";
      package = mkPackageOption config.services.postgres "package" { };
    };

    dblab = {
      enable = mkEnableOption "Enable dblab database client" // {
        default = cfg.sqlite.enable || cfg.postgres.enable;
      };
      package = mkPackageOption pkgs "dblab" { };
    };

    harlequin = {
      enable = mkEnableOption "Enable harlequin database IDE" // {
        default = cfg.sqlite.enable || (cfg.postgres.enable && (!cfg.rainfrog.enable));
      };
      package = mkPackageOption pkgs "harlequin" { };
    };

    lazysql = {
      enable = mkEnableOption "Enable lazysql database client" // {
        default =
          (cfg.sqlite.enable || cfg.postgres.enable)
          && (!cfg.harlequin.enable || (!cfg.rainfrog.enable) || (!cfg.dblab.enable));
      };
      package = mkPackageOption pkgs "lazysql" { };
    };

    rainfrog = {
      enable = mkEnableOption "Enable rainfrog postgres client" // {
        default = cfg.postgres.enable;
      };
      package = mkPackageOption pkgs "rainfrog" { };
    };
  };

  config = mkIf cfg.enable {
    packages =
      optional cfg.sqlite.enable cfg.sqlite.package
      ++ optional cfg.postgres.enable cfg.postgres.package
      ++ optional cfg.dblab.enable cfg.dblab.package
      ++ optional cfg.harlequin.enable cfg.harlequin.package
      ++ optional cfg.lazysql.enable cfg.lazysql.package
      ++ optional cfg.rainfrog.enable cfg.rainfrog.package;

    treefmt.config.programs = {
      sqruff.enable = mkDefault (cfg.sqlite.enable or cfg.postgres.enable);
    };

    knopki.menu.commands = map (cmd: cmd // { category = "db"; }) (
      optional cfg.sqlite.enable {
        inherit (cfg.sqlite) package;
      }
      ++ optionals cfg.postgres.enable (
        map
          (name: {
            inherit name;
            inherit (cfg.postgres) package;
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
      ++ optional cfg.dblab.enable {
        inherit (cfg.dblab) package;
        name = "dblab";
      }
      ++ optional cfg.harlequin.enable {
        inherit (cfg.harlequin) package;
      }
      ++ optional cfg.lazysql.enable {
        inherit (cfg.lazysql) package;
      }
      ++ optional cfg.rainfrog.enable {
        inherit (cfg.rainfrog) package;
      }
    );
  };
}
