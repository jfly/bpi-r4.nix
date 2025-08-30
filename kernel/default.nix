{ inputs, ... }:
{
  perSystem =
    { pkgs, ... }:
    {
      packages.kernel = pkgs.callPackage ./kernel.nix { inherit inputs; };
    };
}
