{
  lib,
  ...
}:
let
  inherit (builtins) attrValues;
  inherit (lib.modules) mkDefault;
  myModules = import ./modules-list.nix;
  myLib = import ./lib.nix { inherit lib; };
in
{
  _module.args.myLib = myLib;

  imports = attrValues myModules;

  devenv.warnOnNewVersion = mkDefault false;
}
