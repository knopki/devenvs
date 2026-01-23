args@{ lib, pkgs, ... }:
let
  inherit (lib.modules) mkDefault;
  inherit (lib.lists) map;

  imports-args = args // {
    # inherit recipes-lib;
    # inherit pkgs-unstable;
  };
in
{

  imports = map (modulePath: import modulePath imports-args) [
    ../modules/git.nix
    ../modules/json.nix
  ];

  knopki.git.enable = mkDefault true;
  knopki.json.enable = mkDefault true;
}
