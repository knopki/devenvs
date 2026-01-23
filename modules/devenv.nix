{ config, lib, pkgs, ... }:
let
  inherit (lib.lists) map;

  imports-args = {
    inherit config lib pkgs;
  };
in
{
  imports = map (modulePath: import modulePath imports-args) [
    ./git.nix
    ./json.nix
    ./toml.nix
    ./xml.nix
  ];
}
