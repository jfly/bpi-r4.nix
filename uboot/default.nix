{ inputs, ... }:
{
  perSystem =
    { pkgs, self', ... }:
    {
      packages.uboot-uart = pkgs.pkgsCross.aarch64-multiplatform.callPackage ./uboot.nix {
        inherit inputs;
        uartBoot = true;
      };

      packages.flash-uart = pkgs.writeShellApplication {
        name = "flash-uart";
        runtimeInputs = with pkgs; [
          mtk-uartboot
        ];
        text = ''
          exec mtk_uartboot \
            --aarch64 \
            --payload ${self'.packages.uboot-uart}/bl2.bin \
            --fip ${self'.packages.uboot-uart}/fip.bin \
            "$@"
        '';
      };
    };
}
