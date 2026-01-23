{ config, lib, pkgs, ... }:
let
  inherit (lib.lists) map;

  imports-args = {
    inherit config lib pkgs;
  };
in
{
  imports = map (modulePath: import modulePath imports-args) [
    ./modules/json.nix
    ./modules/toml.nix
  ];

  knopki.json.enable = true;
  knopki.toml.enable = true;

  env.GREET = "devenvs";

  treefmt.enable = true;
}
