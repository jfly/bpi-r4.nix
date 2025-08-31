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
        ./nixos-modules
        ./uboot
        ./example-systems
      ];

      flake.overlays.default = final: prev: {
        # <<< TODO: naming? `linuxPackages_bpi-r4`? should i be calling `final.linuxPackagesFor` or should the user? >>>
        linuxPackages_bpi-r4 = final.linuxPackagesFor (final.callPackage ./kernel.nix { inherit inputs; });

        # TODO: remove. Matt says mainline Linux works fine.
        mt7996-firmware =
          let
            mt76-owrt = final.fetchFromGitHub {
              owner = "openwrt";
              repo = "mt76";
              rev = "32ca2b6db354db090eb306e9f5b85651e92dfa8b"; # <<< Is this magical? Should it be a flake input? >>>
              hash = "sha256-X2FfiCkRVSzBWTltGKprIPJha+qV9Kg8+41l56NCGbs=";
            };
          in
          final.runCommand "mt7996-firmware" { } ''
            mkdir -p $out/lib/firmware/mediatek/
            cp -r ${mt76-owrt}/firmware/mt7996/ $out/lib/firmware/mediatek/
          '';
      };
    };
}
