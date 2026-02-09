_: {
  knopki = {
    menu.enable = true;
    git = {
      enable = true;
      withGitHooks = true;
      difftastic.enable = true;
      gitleaks.enable = true;
      lazygit.enable = true;
    };
    nix = {
      enable = true;
      nixfmt.enable = true;
      deadnix.enable = true;
      statix.enable = true;
    };
    markdown = {
      enable = true;
      glow.enable = true;
      lychee.enable = true;
      marksman.enable = true;
      markdownlint.enable = true;
    };
    yaml = {
      enable = true;
      yamllint.enable = true;
    };
  };

  git-hooks.enable = true;
  treefmt.enable = true;
}
