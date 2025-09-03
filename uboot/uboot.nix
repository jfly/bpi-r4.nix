{
  lib,
  pkgs,
  inputs,
  uartBoot,
  combined ? false,
  ...
}:
let
  uboot = pkgs.buildUBoot {
    src = inputs.uboot;
    version = "2025.07-bpi"; # <<< eh? >>>
    defconfig = "mt7988a_bananapi_bpi-r4-bootstd_defconfig";
    filesToInstall = [ "u-boot.bin" ];

    # If `uartBoot`, don't automatically boot into anything. Otherwise, the
    # default is to discover a boot device and boot it, which is exactly what
    # we want the normal boot flow to be.
    extraConfig = lib.optionalString uartBoot ''
      CONFIG_BOOTCOMMAND="true"
    '';
  };

  # <<< TODO This can get cleaner once <https://github.com/NixOS/nixpkgs/commit/4092d0555e48589472e0795cd10a110cce29afe9> lands in nixos-unstable.
  tfA = pkgs.buildArmTrustedFirmware {
    platform = "mt7988";
    makeFlags = [
      "BL33=${uboot}/u-boot.bin" # FIP-ify our uboot
      "BOOT_DEVICE=${if uartBoot then "ram" else "spim-nand"}"
      "DRAM_USE_COMB=1" # you're supposed to use this one, sayeth mediatek # <<< source?
      "DDR4_4BG_MODE=0" # disable large RAM support, for some reason this breaks things
      "USE_MKIMAGE=1" # use uboot mkimage instead of vendor mtk tool #<<< why?
      "bl2"
      "fip"
    ]
    ++ lib.optionals uartBoot [
      "RAM_BOOT_UART_DL=1"
    ];
    filesToInstall =
      (
        if uartBoot then
          [
            "build/mt7988/release/bl2.bin"
          ]
        else
          [
            "build/mt7988/release/bl2.img"
          ]
      )
      ++ [
        "build/mt7988/release/fip.bin"
      ];
  };

  # I believe this can get cleaner once <https://github.com/NixOS/nixpkgs/commit/4092d0555e48589472e0795cd10a110cce29afe9> lands in nixos-unstable.
  tfA' = tfA.overrideAttrs (old: {
    src = pkgs.fetchFromGitHub {
      # <<< flake input? is this a magical rev?
      owner = "mtk-openwrt";
      repo = "arm-trusted-firmware";
      rev = "e090770684e775711a624e68e0b28112227a4c38";
      hash = "sha256-VI5OB2nWdXUjkSuUXl/0yQN+/aJp9Jkt+hy7DlL+PMg=";
    };
    nativeBuildInputs =
      old.nativeBuildInputs
      ++ (with pkgs; [
        dtc
        openssl
        ubootTools
        which
      ]);
  });
  combinedImage =
    let
      # https://github.com/mtk-openwrt/arm-trusted-firmware/blob/mtksoc-20250711/plat/mediatek/mt7988/bl2/bl2_dev_spi_nand.c#L11
      fipBaseBytes = lib.fromHexString "0x580000";
    in
    pkgs.runCommand "uboot.img" { } ''
      dd if=${tfA'}/bl2.img of=uboot.img
      dd if=${tfA'}/fip.bin of=uboot.img conv=notrunc bs=512 oseek=${fipBaseBytes}B

      mv uboot.img $out
    '';
in
if combined then combinedImage else tfA'
