{
  config,
  lib,
  myLib,
  pkgs,
  ...
}:
let
  inherit (lib.modules) mkAliasOptionModule mkDefault mkIf;
  inherit (lib.options) mkEnableOption mkPackageOption;
  inherit (lib.lists) optional;
  inherit (lib.meta) getExe;
  inherit (myLib) commandsFromConfigs packagesFromConfigs;

  cfg = config.knopki.terraform;
in
{
  imports = [
    (mkAliasOptionModule [ "knopki" "terraform" "package" ] [ "languages" "terraform" "package" ])
    (mkAliasOptionModule [ "knopki" "terraform" "version" ] [ "languages" "terraform" "version" ])
  ];

  options.knopki.terraform = {
    enable = mkEnableOption "Enable terraform support" // {
      default = cfg.terragrunt.enable || cfg.terramate.enable;
    };

    checkov = {
      enable = mkEnableOption "Enable checkov linter";
      package = mkPackageOption pkgs "checkov" { };
    };

    tf-summarize = {
      enable = mkEnableOption "Enable tf-summarize";
      package = mkPackageOption pkgs "tf-summarize" { };
    };

    tfautomv = {
      enable = mkEnableOption "Enable tfautomv";
      package = mkPackageOption pkgs "tfautomv" { };
    };

    tflint = {
      enable = mkEnableOption "Enable tflint linter";
      package = mkPackageOption pkgs "tflint" { };
    };

    terraform-docs = {
      enable = mkEnableOption "Enable terraform-docs";
      package = mkPackageOption pkgs "terraform-docs" { };
    };

    terraformer = {
      enable = mkEnableOption "Enable terraformer";
      package = mkPackageOption pkgs "terraformer" { };
    };

    terragrunt = {
      enable = mkEnableOption "Enable terragrunt";
      package = mkPackageOption pkgs "terragrunt" { };
    };

    terramate = {
      enable = mkEnableOption "Enable terramate";
      package = mkPackageOption pkgs "terramate" { };
    };
  };

  config = mkIf cfg.enable {
    packages = packagesFromConfigs [
      cfg
      cfg.checkov
      cfg.tfautomv
      cfg.tflint
      cfg.tf-summarize
      cfg.terraform-docs
      cfg.terraformer
      cfg.terragrunt
      cfg.terramate
    ];

    languages.terraform = {
      enable = mkDefault true;
      lsp.enable = mkDefault true;
    };

    git-hooks.hooks = {
      checkov = {
        enable = mkDefault cfg.checkov.enable;
        name = "Checkov";
        package = mkDefault cfg.checkov.package;
        pass_filenames = mkDefault false;
        entry = mkDefault ''
          ${getExe cfg.checkov.package}
        '';
      };
      terraform-format = {
        enable = mkDefault true;
        package = mkDefault cfg.package;
      };
      terraform-validate = {
        enable = mkDefault true;
        package = mkDefault cfg.package;
      };
      terramate-format = {
        enable = mkDefault cfg.terramate.enable;
        name = "terramate-format";
        description = "Format HCL files";
        package = mkDefault cfg.terramate.package;
        entry = "terramate fmt --detailed-exit-code";
        files = "\\.hcl$";
      };
      terramate-generate = {
        enable = mkDefault cfg.terramate.enable;
        name = "terramate-generate";
        description = "Terramate codegen";
        package = mkDefault cfg.terramate.package;
        entry = "terramate generate --detailed-exit-code";
        files = "\\.(hcl|tf|tfvars)$";
        pass_filenames = false;
      };
      tflint.enable = mkDefault cfg.tflint.enable;
    };

    treefmt.config = {
      settings.formatter."terramate-format" = mkIf config.knopki.terraform.terramate.enable {
        command = "${config.knopki.terraform.terramate.package}/bin/terramate";
        options = [
          "fmt"
        ];
        includes = [ "*.hcl" ];
      };
      programs = {
        terraform = {
          inherit (cfg) package;
          enable = mkDefault true;
        };
      };
    };

    knopki.menu.commands =
      commandsFromConfigs { category = "terraform"; } [
        cfg
        cfg.checkov
        cfg.tfautomv
        cfg.tflint
        cfg.tf-summarize
        cfg.terraform-docs
        cfg.terraformer
        cfg.terragrunt
      ]
      ++ optional cfg.terramate.enable {
        inherit (cfg.terramate) package;
        name = "terramate";
        category = "terraform";
      };
  };
}
