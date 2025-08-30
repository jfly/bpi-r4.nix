{
  perSystem =
    { pkgs, ... }:
    {
      packages.firmware = pkgs.callPackage ./firmware.nix { };
    };
}
