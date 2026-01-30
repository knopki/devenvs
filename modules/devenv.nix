{ lib, config, pkgs, ... }:
let
  inherit (builtins) attrValues;
  inherit (lib.modules) mkDefault;
  inherit (config.lib) mkOverrideDefault;
  myModules = import ./modules-list.nix;
in
{
  _module.args.myLib = import ./lib.nix { inherit lib; };

  imports = attrValues myModules;

  devenv.warnOnNewVersion = mkDefault false;

  git-hooks = {
    enable = mkDefault false;
    package = mkOverrideDefault pkgs.prek;
    excludes = [
      "^.devenv\..*/"
      "^.git/"
    ];
  };

  treefmt.config.settings.global.excludes = [
    ".devenv/*"
    ".devenv.*/*"
    ".direnv/*"
    ".git/*"
  ];
}
