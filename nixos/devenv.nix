{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib.modules) mkDefault;
  inherit (lib.lists) map;

  imports-args = {
    inherit config lib pkgs;
  };
in
{
  imports = map (modulePath: import modulePath imports-args) [
    ../modules/git.nix
    ../modules/json.nix
    ../modules/toml.nix
  ];

  knopki.git.enable = mkDefault true;
  knopki.json.enable = mkDefault true;
  knopki.toml.enable = mkDefault true;
}
