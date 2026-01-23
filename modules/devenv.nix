{ lib, ... }:
let
  inherit (builtins) attrValues;
  inherit (lib.modules) mkDefault;
  myModules = import ./modules-list.nix;
in
{
  imports = attrValues myModules;

  devenv.warnOnNewVersion = mkDefault false;
}
