{
  lib,
  pkgs,
  inputs,
  ...
}:

pkgs.buildLinux {
  version = "6.17.0-rc3";
  modDirVersion = "6.17.0-rc3";
  src = inputs.linux;

  kernelPatches = [
    {
      name = "fix-build-with-phylink-builtin";
      patch = null;
      structuredExtraConfig = {
        FWNODE_PCS = lib.kernel.yes;
        PCS_MTK_USXGMII = lib.kernel.yes;
      };
    }
  ];
}
