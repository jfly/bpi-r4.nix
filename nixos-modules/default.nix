{ self, ... }:
{
  flake.nixosModules.default =
    { pkgs, ... }:
    {
      hardware = {
        deviceTree = {
          enable = true;
          filter = null;
          name = "mediatek/mt7988a-bananapi-bpi-r4.dtb";
        };

        #<<< what is this? where does it belong? >>>
        deviceTree.overlays = [
          {
            name = "bpi-r4-emmc";
            dtsText = ''
              /dts-v1/;
              /plugin/;

              / {
                compatible = "bananapi,bpi-r4";
              };

              &mmc0 {
                pinctrl-names = "default", "state_uhs";
                pinctrl-0 = <&mmc0_pins_emmc_51>;
                pinctrl-1 = <&mmc0_pins_emmc_51>;
                bus-width = <8>;
                max-frequency = <200000000>;
                cap-mmc-highspeed;
                mmc-hs200-1_8v;
                mmc-hs400-1_8v;
                hs400-ds-delay = <0x12814>;
                vqmmc-supply = <&reg_1p8v>;
                vmmc-supply = <&reg_3p3v>;
                non-removable;
                no-sd;
                no-sdio;
                status = "okay";
              };
            '';
          }
        ];
      };

      nixpkgs.overlays = [ self.overlays.default ];
      boot = {
        kernelPackages = pkgs.linuxPackages_bpi-r4;

        loader.efi.installDeviceTree = true;

        kernelParams = [
          "console=ttyS0,115200"
          "clk_ignore_unused" # FIXME: fix the clock tree ffs
          # <<< "cma=256M" # Needed to fit NVMe buffers
        ];
      };
    };
}
