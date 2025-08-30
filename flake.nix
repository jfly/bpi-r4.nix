{
  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";

    git-hooks-nix = {
      url = "github:cachix/git-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    uboot-bpi-r4 = {
      url = "github:K900/u-boot/bpi-r4";
      flake = false;
    };

    linux-bpi-r4 = {
      url = "github:K900/linux/bpi-r4-test";
      flake = false;
    };

    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    systems.url = "github:nix-systems/default";

    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = import inputs.systems;
      imports = [
        ./formatting.nix
        ./router.nix
        ./uboot
        ./kernel
        ./firmware
      ];
    };
}
