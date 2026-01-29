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
  inherit (myLib) commandsFromConfigs packagesFromConfigs;

  cfg = config.knopki.nixos;
in
{
  options.knopki.nixos = {
    enable = mkEnableOption "Enable NixOS tools";

    nh = {
      enable = mkEnableOption "Enable nh tool";
      package = mkPackageOption pkgs "nh" { };
    };

    nix-inspect = {
      enable = mkEnableOption "Enable nix-inspect tool";
      package = mkPackageOption pkgs "nix-inspect" { };
    };

    nixos-anywhere = {
      enable = mkEnableOption "Enable nixos-anywhere tool";
      package = mkPackageOption pkgs "nixos-anywhere" { };
    };

    nixos-build-vms = {
      enable = mkEnableOption "Enable nixos-build-vms tool";
      package = mkPackageOption pkgs "nixos-build-vms" { };
    };

    nixos-rebuild = {
      enable = mkEnableOption "Enable nixos-rebuild tool";
      package = mkPackageOption pkgs "nixos-rebuild-ng" { };
    };

    nixos-install-tools = {
      enable = mkEnableOption "Enable nixos install tools";
      package = mkPackageOption pkgs "nixos-install-tools" { };
    };
  };

  config = mkIf cfg.enable {
    knopki = {
      git.enable = mkDefault true;
      nix.enable = mkDefault true;
      secrets.sops.enable = mkDefault true;
      shell.enable = mkDefault true;
    };

    packages =
      packagesFromConfigs [
        cfg.nh
        cfg.nix-inspect
        cfg.nixos-anywhere
        cfg.nixos-build-vms
        cfg.nixos-rebuild
      ]
      ++ optional cfg.nixos-rebuild.enable cfg.nixos-install-tools.package;

    knopki.menu.commands =
      commandsFromConfigs { category = "nixos"; } [
        cfg.nh
        cfg.nix-inspect
        cfg.nixos-anywhere
        cfg.nixos-build-vms
        cfg.nixos-rebuild
      ]
      ++ optionals cfg.nixos-install-tools.enable (
        map
          (name: {
            inherit name;
            inherit (cfg.nixos-install-tools) package;
            category = "nixos";
          })
          [
            "nixos-enter"
            "nixos-generate-config"
            "nixos-install"
          ]
      );

    # do not format keys
    treefmt.config.settings.global.excludes = [
      "*.asc"
      ".sops.yaml"
      "secrets/*.yaml"
    ];
  };
}
