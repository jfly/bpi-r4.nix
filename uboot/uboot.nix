{
  pkgs,
  inputs,
  ...
}:
let
  uboot = pkgs.buildUBoot {
    src = inputs.uboot;
    version = "2025.07-bpi"; # <<< eh? >>>
    defconfig = "mt7988a_bananapi_bpi-r4-bootstd_defconfig";
    filesToInstall = [ "u-boot.bin" ];
  };

  tfA = pkgs.buildArmTrustedFirmware {
    platform = "mt7988";
    extraMakeFlags = [
      "BL33=${uboot}/u-boot.bin" # FIP-ify our uboot
      "BOOT_DEVICE=spim-nand" # boot from NAND flash
      "DRAM_USE_COMB=1" # you're supposed to use this one, sayeth mediatek # <<< source?
      "DDR4_4BG_MODE=0" # disable large RAM support, for some reason this breaks things
      "USE_MKIMAGE=1" # use uboot mkimage instead of vendor mtk tool #<<< why?
      "bl2"
      "fip"
    ];
    filesToInstall = [
      "build/mt7988/release/bl2.img"
      "build/mt7988/release/fip.bin"
    ];
  };

  tfA' = tfA.overrideAttrs (old: {
    src = pkgs.fetchFromGitHub {
      # <<< flake input? is this a magical rev?
      owner = "mtk-openwrt";
      repo = "arm-trusted-firmware";
      rev = "e090770684e775711a624e68e0b28112227a4c38";
      hash = "sha256-VI5OB2nWdXUjkSuUXl/0yQN+/aJp9Jkt+hy7DlL+PMg=";
    };
    # This can get cleaner once <https://github.com/NixOS/nixpkgs/pull/434135> lands.
    nativeBuildInputs =
      old.nativeBuildInputs
      ++ (with pkgs; [
        dtc
        openssl
        ubootTools
        which
      ]);
  });
in
pkgs.runCommand "uboot.img" { } ''
  dd if=${tfA'}/bl2.img of=uboot.img
  # magic offset hardcoded in BL2 by default <<< TODO: ??? this does not match any numbers in https://github.com/K900/u-boot/blob/bpi-r4/arch/arm/dts/mt7988a-bananapi-bpi-r4.dtsi >>>
  dd if=${tfA'}/fip.bin of=uboot.img conv=notrunc bs=512 seek=$((0x580000 / 512))

  mkdir $out
  mv uboot.img $out/
''
