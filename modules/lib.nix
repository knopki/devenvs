{ lib, ... }:
let
  inherit (builtins) concatMap;
  inherit (lib.lists) optional;
in
{
  # Priority 500: between mkDefault (1000) and actual default (100)
  mkOverrideDefault = lib.mkOverride 500;

  # Convert list of attrs with enable bool and package to the a list of menu commands
  commandsFromConfigs = common: concatMap (x: optional x.enable (common // { inherit (x) package; }));

  # Convert list of attrs with enable bool and package to a list of packages
  packagesFromConfigs = concatMap (x: optional x.enable x.package);
}
