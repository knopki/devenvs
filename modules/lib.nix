{ lib, ... }:
let
  inherit (builtins) concatMap;
  inherit (lib.lists) optional;
in
{
  # Convert list of attrs with enable bool and package to list of packages
  packagesFromConfigs = concatMap (x: optional x.enable x.package);
}
