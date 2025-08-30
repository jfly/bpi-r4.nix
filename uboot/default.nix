{ inputs, ... }:
{
  perSystem =
    { pkgs, ... }:
    {
      packages.uboot = pkgs.callPackage ./uboot.nix { inherit inputs; };
    };
}
