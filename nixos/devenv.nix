args@{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib.modules) mkIf mkDefault;
  inherit (lib.lists) map;
  inherit (lib.types) bool;
  inherit (lib.options) mkOption;

  imports-args = args // {
    # inherit recipes-lib;
    # inherit pkgs-unstable;
  };

  cfg = config.knopki;
in
{

  imports = map (modulePath: import modulePath imports-args) [ ../modules/git.nix ];

  env.GREET = mkDefault "NixOS devenv";

  knopki.git.enable = mkDefault true;
}
