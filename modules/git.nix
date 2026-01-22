{
  config,
  lib,
  pkgs,
  ...
}:let
  inherit (lib.modules) mkIf;
  inherit (lib.options) mkEnableOption;

  cfg = config.knopki.git;

  # git = cfg.package;
in
{

  options.knopki.git = {
    enable = mkEnableOption "Enable Git";
  };

  config = mkIf cfg.enable {
    packages = [
      pkgs.git
      pkgs.lazygit # Git terminal UI
    ];

    difftastic.enable = true;

    delta.enable = true;

    # enterShell = ''
    #   git --version
    #   lazygit --version
    # '';
  };
}
