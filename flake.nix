{
  inputs = {
    # <<< TODO: Verify if this version of arm-trusted-firmware works OK. It's
    # not the version K900 uses:
    # <https://gitlab.com/K900/nix/-/blob/b63345677f3d434e7fd0787662f59bae23efea95/shared/platform/bpi-r4.nix#L40>.
    arm-trusted-firmware = {
      url = "github:mtk-openwrt/arm-trusted-firmware/mtksoc";
      flake = false;
    };

    flake-parts.url = "github:hercules-ci/flake-parts";

    git-hooks-nix = {
      url = "github:cachix/git-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    linux = {
      url = "github:K900/linux/bpi-r4-test";
      flake = false;
    };

    # TODO: revert once <https://github.com/NixOS/nixpkgs/pull/439700> lands in nixos-unstable.
    # nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs.url = "github:jfly/nixpkgs/move-installDeviceTree";

    systems.url = "github:nix-systems/default";

    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    uboot = {
      url = "github:K900/u-boot/bpi-r4";
      flake = false;
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
