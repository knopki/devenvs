# Recipes for devenv.sh

An opinionated collection of modular presets and configurations for
[devenv.sh](https://devenv.sh), designed to streamline development environment
setup.

## Features

- Modular Architecture: Easily toggle specific configurations via a unified
  interface.
- Overridable Defaults: Most settings are defined as defaults that can be easily
  overridden. disabled if you need.
- Friendly Menu: Built-in menu with all installed tools.
- Best Practices: Standardized presets, formatting, linters and common
  development tools.

## Installation

To use these recipes, add `knopki-devenvs` to your `devenv.yaml` and include the
`knopki-devenvs/modules` in your imports:

```yaml
# devenv.yaml
inputs:
  knopki-devenvs:
    url: github:knopki/devenvs
    flake: false
allowUnfree: true
imports:
  - knopki-devenvs/modules
```

After updating the configuration, sync your lockfile:

```sh
devenv update
```

## Usage

Enable the desired modules within your `devenv.nix` file. Below is an example
configuration for a Nix-based project:

```nix
# devenv.nix
{ inputs, pkgs, ... }: {
  # Enable custom presets
  knopki.nixos.enable = true;

  # Enable an interactive CLI menu for the project
  knopki.menu.enable = true;

  # Disable something that is enabled by default (for example)
  git-hooks.hooks.no-commit-to-branch.enable = false;

  # Enable auto-formatting
  treefmt.enable = true;
}
```

### Integration: treefmt

Note that if you enable `treefmt`, you must explicitly add the `treefmt-nix`
input to your `devenv.yaml` as per the
[official documentation](https://devenv.sh/integrations/treefmt/):

```yaml
# devenv.yaml
inputs:
  treefmt-nix:
    url: github:numtide/treefmt-nix
    inputs:
      nixpkgs:
        follows: nixpkgs
```
