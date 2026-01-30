{
  config,
  lib,
  myLib,
  pkgs,
  ...
}:
let
  inherit (lib.modules) mkDefault mkIf;
  inherit (lib.options) mkEnableOption mkPackageOption;
  inherit (lib.lists) optional;
  inherit (lib.meta) getExe;
  inherit (config.lib) mkOverrideDefault;
  inherit (myLib) commandsFromConfigs packagesFromConfigs;

  cfg = config.knopki.terraform;
in
{
  options.knopki.terraform = {
    enable = mkEnableOption "Enable terraform support" // {
      default = cfg.terragrunt.enable || cfg.terramate.enable;
    };
    package = mkPackageOption pkgs "terraform" { };

    lsp = {
      enable = mkEnableOption "Enable LSP";
      package = mkPackageOption pkgs "terraform-ls" { };
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

    tfsec = {
      enable = mkEnableOption "Enable tfsec linter";
      package = mkPackageOption pkgs "tfsec" { };
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
      cfg.tfsec
      cfg.tf-summarize
      cfg.terraform-docs
      cfg.terraformer
      cfg.terragrunt
      cfg.terramate
      cfg.lsp
    ];

    git-hooks = {
      excludes = [ "\\.terraform" ];
      hooks = {
        checkov = {
          enable = mkOverrideDefault cfg.checkov.enable;
          name = "Checkov";
          package = mkDefault cfg.checkov.package;
          pass_filenames = mkOverrideDefault false;
          entry = mkOverrideDefault ''
            ${getExe cfg.checkov.package}
          '';
        };
        terraform-format = {
          enable = mkOverrideDefault true;
          package = mkOverrideDefault cfg.package;
        };
        terraform-validate = {
          enable = mkOverrideDefault true;
          package = mkOverrideDefault cfg.package;
        };
        terramate-format = {
          enable = mkOverrideDefault cfg.terramate.enable;
          name = "terramate-format";
          description = "Format HCL files";
          package = mkOverrideDefault cfg.terramate.package;
          entry = mkOverrideDefault "terramate fmt --detailed-exit-code";
          files = mkOverrideDefault "\\.hcl$";
        };
        terramate-generate = {
          enable = mkOverrideDefault cfg.terramate.enable;
          name = "terramate-generate";
          description = "Terramate codegen";
          package = mkOverrideDefault cfg.terramate.package;
          entry = mkOverrideDefault "terramate generate --detailed-exit-code";
          files = mkOverrideDefault "\\.(hcl|tf|tfvars)$";
          pass_filenames = false;
        };
        tflint.enable = mkOverrideDefault cfg.tflint.enable;
        tfsec = {
          enable = mkOverrideDefault cfg.tfsec.enable;
          name = "tfsec";
          description = "tfsec security scanner";
          package = mkOverrideDefault cfg.tfsec.package;
          entry = "tfsec";
          files = "\\.(hcl|tf|tfvars)$";
          pass_filenames = false;
        };
      };
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
          enable = mkOverrideDefault true;
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
        cfg.lsp
      ]
      ++ optional cfg.terramate.enable {
        inherit (cfg.terramate) package;
        name = "terramate";
        category = "terraform";
      }
      ++ optional cfg.tfsec.enable {
        inherit (cfg.tfsec) package;
        name = "tfsec";
        category = "terraform";
      };
  };
}
