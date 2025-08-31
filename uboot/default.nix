{ inputs, ... }:
{
  perSystem =
    { pkgs, ... }:
    {
      packages.uboot = pkgs.pkgsCross.aarch64-multiplatform.callPackage ./uboot.nix { inherit inputs; };
    };
}
