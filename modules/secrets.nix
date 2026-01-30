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

  cfg = config.knopki.secrets;
in
{
  options.knopki.secrets = {
    enable = mkEnableOption "Enable secret management tools" // {
      default = cfg.age.enable || cfg.sops.enable;
    };

    age = {
      enable = mkEnableOption "Enable age tool" // {
        default = cfg.sops.enable;
      };
      package = mkPackageOption pkgs "age" { };
    };

    libsecret = {
      enable = mkEnableOption "Enable libsecret tools (Linux)";
      package = mkPackageOption pkgs "libsecret" { };
    };

    sops = {
      enable = mkEnableOption "Enable SOPS integration";
      package = mkPackageOption pkgs "sops" { };
    };
  };

  config = mkIf cfg.enable {
    packages = packagesFromConfigs [
      cfg.age
      cfg.libsecret
      cfg.sops
    ];

    git-hooks.hooks = {
      pre-commit-hook-ensure-sops = mkOverrideDefault cfg.sops.enable;
    };

    knopki.menu.commands = commandsFromConfigs { category = "secrets"; } [
      cfg.age
      cfg.libsecret
      cfg.sops
    ];
  };
}
