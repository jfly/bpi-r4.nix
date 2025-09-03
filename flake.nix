{
  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";

    git-hooks-nix = {
      url = "github:cachix/git-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    uboot = {
      url = "github:K900/u-boot/bpi-r4";
      flake = false;
    };

    linux = {
      url = "github:K900/linux/bpi-r4-test";
      flake = false;
    };

    # TODO: revert once <https://github.com/NixOS/nixpkgs/pull/439700> lands in nixos-unstable.
    # nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs.url = "github:jfly/nixpkgs/move-installDeviceTree-backport";

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
        ./nixos-modules
        ./uboot
        ./liveusb
      ];

      flake.overlays.default = final: prev: {
        linuxPackages_bpi-r4 = final.linuxPackagesFor (final.callPackage ./kernel.nix { inherit inputs; });
      };
    };
}
