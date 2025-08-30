{ self, ... }:
{
  flake.nixosModules.default =
    { pkgs, ... }:
    {
      hardware = {
        firmware = [ pkgs.mt7996-firmware ];

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
        kernelPackages = pkgs.linuxPackages_bpir4;

        loader.systemd-boot.enable = true;

        kernelParams = [
          "console=ttyS0,115200"
          "clk_ignore_unused" # FIXME: fix the clock tree ffs
          # <<< "regulator_ignore_unused" # <<<< adding because i'm seeing "vproc: disabling" after ~30 seconds ????
          # <<< # without:
          # <<< # [   33.760577] vproc: disabling
          # <<< # with:
          # <<< # [   33.764081] regulator: Not disabling unused regulators
          # <<< "cma=256M" # Needed to fit NVMe buffers
        ];
        # <<< initrd.availableKernelModules = [ "uas" ];
      };
    };
}
