{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (builtins)
    attrValues
    concatStringsSep
    filter
    foldl'
    sort
    stringLength
    ;
  inherit (lib.modules) mkDefault mkIf;
  inherit (lib.options) literalExpression mkEnableOption mkOption;
  inherit (lib.strings) getVersion;
  inherit (lib.lists) optional;
  inherit (lib.meta) getExe;

  cfg = config.knopki.menu;

  esc = "";

  ansi = {
    bold = "${esc}[1m";
    reset = "${esc}[0m";
  };

  pad = str: num: if num > 0 then pad "${str} " (num - 1) else str;

  commandOptions = {
    name = mkOption {
      type = with lib.types; nullOr str;
      default = null;
      description = ''
        Name of this command.
        Defaults to attribute name of a package.
        If null, command will be skipped.
      '';
    };

    category = mkOption {
      type = lib.types.str;
      default = "";
      description = ''
        Set a free text category under which this command is grouped
        and shown in the help menu.
      '';
    };

    description = mkOption {
      type = with lib.types; nullOr str;
      default = null;
      description = ''
        Describes what the command does in one line of text.
      '';
    };

    package = mkOption {
      type = with lib.types; nullOr package;
      default = null;
      description = ''
        If specified, name and description will be derived from the package.
      '';
    };
  };

  commandsToMenu =
    cmds:
    let
      cleanName =
        { ... }@cmd:
        assert lib.assertMsg (
          cmd.name != null || cmd.package != null
        ) "[[commands]]: some command is missing both a `name` or `package` attribute.";
        let
          name = if cmd.name == null then baseNameOf (getExe cmd.package) else cmd.name;

          description =
            if cmd.description == null then cmd.package.meta.description or "" else cmd.description;

          version = if cmd.package != null then getVersion cmd.package else "";
        in
        cmd // { inherit name description version; };

      commands = map cleanName cmds;

      commandLengths = map ({ name, ... }: stringLength name) commands;

      maxCommandLength = foldl' (max: v: if v > max then v else max) 0 commandLengths;

      versions = map ({ version, ... }: version) commands;

      versionLengths = map stringLength versions;

      maxVersionLength = foldl' (max: v: if v > max then v else max) 0 versionLengths;

      commandCategories = lib.unique (
        (lib.zipAttrsWithNames [ "category" ] (_name: vs: vs) commands).category
      );

      commandByCategoriesSorted = attrValues (
        lib.genAttrs commandCategories (
          category:
          lib.nameValuePair category (
            sort (a: b: a.name < b.name) (filter (x: x.category == category) commands)
          )
        )
      );

      opCat =
        kv:
        let
          category = if kv.name == "" then "general" else kv.name;
          cmd = kv.value;
          opCmd =
            {
              name,
              description,
              version,
              ...
            }:
            let
              len = maxCommandLength - (stringLength name);
              namePart = "${ansi.bold}${pad name len}${ansi.reset}";
              vlen = maxVersionLength - (stringLength version);
              versionPart = pad version vlen;
            in
            concatStringsSep "  " [
              namePart
              versionPart
              description
            ];
        in
        "\n${ansi.bold}[${category}]${ansi.reset}\n\n" + concatStringsSep "\n" (map opCmd cmd);
    in
    concatStringsSep "\n" (map opCat commandByCategoriesSorted) + "\n";
in
{
  options.knopki.menu = {
    enable = mkEnableOption "Enable Main Menu";

    commands = mkOption {
      type =
        with lib.types;
        listOf (submodule {
          options = commandOptions;
        });
      default = [ ];
      description = ''
        Menu entry.
      '';
      example = literalExpression ''
        [
          {
            name = "git";
            description = "git is cool tool";
          }
          {
            package = pkgs.git;
            categoty = "vcs";
          }
        ]
      '';
    };
  };

  config = mkIf cfg.enable {
    knopki.menu.commands = [
      {
        name = "menu";
        description = "prints this menu";
      }
    ]
    ++ optional config.git-hooks.enable {
      package = config.git-hooks.package;
    };

    scripts.menu.exec = mkDefault ''
      ${pkgs.coreutils}/bin/cat <<'MAIN_MENU'
      ${commandsToMenu cfg.commands}
      MAIN_MENU
    '';

    enterShell = lib.modules.mkAfter ''
      menu
    '';
  };
}
