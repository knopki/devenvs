{
  lib,
  pkgs,
  ...
}:
let
  inherit (builtins) attrValues;
  inherit (lib.modules) mkDefault mkOverride;
  myModules = import ./modules-list.nix;
  myLib = import ./lib.nix { inherit lib; };
  inherit (myLib) mkOverrideDefault;
in
{
  _module.args.myLib = myLib;

  imports = attrValues myModules;

  devenv.warnOnNewVersion = mkDefault false;

  git-hooks = {
    enable = mkOverride 999 false;
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
