{ inputs, ... }:
{
  imports = [
    inputs.treefmt-nix.flakeModule
    inputs.git-hooks-nix.flakeModule
  ];

  perSystem.pre-commit.settings.hooks.treefmt.enable = true;

  perSystem.treefmt.programs = {
    nixfmt.enable = true;
  };
}
