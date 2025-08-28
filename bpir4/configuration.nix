{
  inputs,
  config,
  lib,
  pkgs,
  ...
}:
let
  crossPkgs = import inputs.nixpkgs {
    localSystem = "x86_64-linux";
    crossSystem = pkgs.stdenv.hostPlatform;
    inherit (pkgs) overlays config;
  };
in
{
  system.stateVersion = "25.11";
  nixpkgs.hostPlatform = {
    system = "aarch64-linux";
  };
  nixpkgs.buildPlatform = {
    system = "x86_64-linux"; # <<<
  };

  hardware.deviceTree = {
    enable = true;
    filter = null;
    name = "mediatek/mt7988a-bananapi-bpi-r4.dtb";
  };

  hardware.firmware = [
    pkgs.linux-firmware # <<< TODO: optimize to pull just the mediatek stuff >>>
  ];

  services.openssh.enable = true; # <<<
  users.users.root = {
    password = "passpass"; # <<<
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIImw0Xc1buEQ9WOskyGGeg3QwdbU7DTUQBiu02fObDlm"
    ];
  };
  networking.hostName = "bpir4-jfly"; # <<<

  boot = {
    initrd.systemd.enable = true;

    kernelPackages = pkgs.linuxPackages_latest;
    # <<< kernelPackages = crossPkgs.linuxPackages_testing;

    kernelPatches = [
      {
        name = "178-arm64-dts-mediatek-mt7988-add-basic-ethernet-nodes";
        patch = pkgs.fetchpatch {
          url = "https://raw.githubusercontent.com/openwrt/openwrt/664424aaeb4a7b74123cc94c536e42fa925cf8c3/target/linux/mediatek/patches-6.12/178-arm64-dts-mediatek-mt7988-add-basic-ethernet-nodes.patch";
          hash = "sha256-+3Q+xKuru9JJrjN3ixNCt3TrnPewyLogNd8Ziiz5yNc=";
        };
      }
      {
        name = "179-arm64-dts-mediatek-mt7988-add-switch-node.patch";
        patch = pkgs.fetchpatch {
          url = "https://raw.githubusercontent.com/openwrt/openwrt/664424aaeb4a7b74123cc94c536e42fa925cf8c3/target/linux/mediatek/patches-6.12/179-arm64-dts-mediatek-mt7988-add-switch-node.patch";
          hash = "sha256-tKg5UCrsSGGAI0Ji9MOvk5hyq+IQR0UHm+0WPMCH4Io=";
        };
      }
      # <<< { # this landed in linux in 0f63e96e2ab422d1d35def1da75d3df299bf503e
      # <<<   name = "180-arm64-dts-mediatek-mt7988a-bpi-r4-Add-fan-and-coolingmaps.patch";
      # <<<   patch = pkgs.fetchpatch {
      # <<<     url = "https://raw.githubusercontent.com/openwrt/openwrt/664424aaeb4a7b74123cc94c536e42fa925cf8c3/target/linux/mediatek/patches-6.12/180-arm64-dts-mediatek-mt7988a-bpi-r4-Add-fan-and-coolingmaps.patch";
      # <<<     hash = "sha256-AUL7DGWsphnum4h2luyAcN5x2bZfoNvaooSzVmvaHmI=";
      # <<<   };
      # <<< }
      # <<< { # this landed in linux in 6b7642e9d095d33d8034b8b396a2de9e5ecb25a7
      # <<<   name = "181-arm64-dts-mediatek-mt7988a-bpi-r4-configure-spi-nodes.patch";
      # <<<   patch = pkgs.fetchpatch {
      # <<<     url = "https://raw.githubusercontent.com/openwrt/openwrt/664424aaeb4a7b74123cc94c536e42fa925cf8c3/target/linux/mediatek/patches-6.12/181-arm64-dts-mediatek-mt7988a-bpi-r4-configure-spi-nodes.patch";
      # <<<     hash = "sha256-zNfE7Mz4IoZZJKq5cQelInuLPJjl3hoHCnY91pDP3gc=";
      # <<<   };
      # <<< }
      {
        name = "182-arm64-dts-mediatek-mt7988a-bpi-r4-add-proc-supply-for-cci.patch";
        patch = pkgs.fetchpatch {
          url = "https://raw.githubusercontent.com/openwrt/openwrt/664424aaeb4a7b74123cc94c536e42fa925cf8c3/target/linux/mediatek/patches-6.12/182-arm64-dts-mediatek-mt7988a-bpi-r4-add-proc-supply-for-cci.patch";
          hash = "sha256-9WPki0YrrM9ogvAnLeZf0JQ9iPuUHvVDisOB4OjkveQ=";
        };
      }
      {
        name = "183-arm64-dts-mediatek-mt7988a-bpi-r4-add-sfp-cages-and-link-to-gmac.patch";
        patch = pkgs.fetchpatch {
          url = "https://raw.githubusercontent.com/openwrt/openwrt/664424aaeb4a7b74123cc94c536e42fa925cf8c3/target/linux/mediatek/patches-6.12/183-arm64-dts-mediatek-mt7988a-bpi-r4-add-sfp-cages-and-link-to-gmac.patch";
          hash = "sha256-6fnCDLO0N7aJDoGOJNLTwjFJZ9WpkHmT/nkqcv/MOCQ=";
        };
      }
      {
        name = "184-arm64-dts-mediatek-mt7988a-bpi-r4-configure-switch-phys-and-leds.patch";
        patch = pkgs.fetchpatch {
          url = "https://raw.githubusercontent.com/openwrt/openwrt/664424aaeb4a7b74123cc94c536e42fa925cf8c3/target/linux/mediatek/patches-6.12/184-arm64-dts-mediatek-mt7988a-bpi-r4-configure-switch-phys-and-leds.patch";
          hash = "sha256-1emSt7WL6UTsLaLu6lwaslhWJxXFEVDPH+TSAU2Hs8I=";
        };
      }
    ];

    loader.systemd-boot.enable = true;

    kernelParams = [
      "console=ttyS0,115200"
      "clk_ignore_unused" # FIXME: fix the clock tree ffs
      "regulator_ignore_unused" # <<<< adding because i'm seeing "vproc: disabling" after ~30 seconds ????
      # without:
      # [   33.760577] vproc: disabling
      # with:
      # [   33.764081] regulator: Not disabling unused regulators
      # <<< "cma=256M" # Needed to fit NVMe buffers
    ]; # <<< why? >>>
    initrd.availableKernelModules = [ "uas" ];
    growPartition = true;

    consoleLogLevel = 7; # <<<
  };

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-label/nixos";
      fsType = "ext4";
      options = [ "noatime" ];
    };
  };

  system.build = {
    sdImage = import "${inputs.nixpkgs}/nixos/lib/make-disk-image.nix" {
      name = "bpi-r4-sd-image";
      copyChannel = false;
      fsType = "ext4";
      partitionTableType = "efi";
      inherit config lib pkgs;
    };

    bpir4-firmware =
      (crossPkgs.buildArmTrustedFirmware rec {
        src = pkgs.fetchFromGitHub {
          owner = "mtk-openwrt";
          repo = "arm-trusted-firmware";
          rev = "78a0dfd927bb00ce973a1f8eb4079df0f755887a"; # https://github.com/mtk-openwrt/arm-trusted-firmware/tree/mtksoc-20250711
          hash = "sha256-m9ApkBVf0I11rNg68vxofGRJ+BcnlM6C+Zrn8TfMvbY=";
        };
        platform = "mt7988";
        extraMeta.platforms = [ "aarch64-linux" ];
        filesToInstall = [
          "build/${platform}/release/bl2.img"
          "build/${platform}/release/fip.bin"
        ];
        extraMakeFlags =
          let
            uboot-mt7988_bpir4_emmc =
              (crossPkgs.buildUBoot {
                defconfig = "mt7988a_bananapi_bpi-r4-emmc_defconfig";
                extraMeta.platforms = [ "aarch64-linux" ];
                filesToInstall = [ "u-boot.bin" ];
                patches = [
                  (pkgs.fetchpatch {
                    url = "https://raw.githubusercontent.com/openwrt/openwrt/6fbf6d0cfd080230ce4ca72605580b0c188db8a1/package/boot/uboot-mediatek/patches/305-mt7988-generic-reset-button-ignore-env.patch";
                    hash = "sha256-da2NLEdyt2sVSlfgcTTzV5gMQkP2Qg7cNYDwSxCAGxA=";
                  })
                  (pkgs.fetchpatch {
                    url = "https://raw.githubusercontent.com/openwrt/openwrt/6fbf6d0cfd080230ce4ca72605580b0c188db8a1/package/boot/uboot-mediatek/patches/310-mt7988-select-rootdisk.patch";
                    hash = "sha256-ifByt4RwJ3LIo4S6f25jUi2ByRes3HrvNB2nYPDNiWk=";
                  })
                  (pkgs.fetchpatch {
                    url = "https://raw.githubusercontent.com/openwrt/openwrt/6fbf6d0cfd080230ce4ca72605580b0c188db8a1/package/boot/uboot-mediatek/patches/450-add-bpi-r4.patch";
                    hash = "sha256-jC8YQKrgzb2F4F8YQ3ZgS5yrQC+AAM6H+A9G7NT9Ngk=";
                  })
                  (pkgs.fetchpatch {
                    name = "Update devicetree definition for FIP";
                    url = "https://github.com/jfly/u-boot/commit/275257208653f06b6addd7e0cab8c4c2df0dded8.diff";
                    hash = "sha256-+SowR1NMAysFykzmIRmo+n6ZJXx9SLCzXF1nDK6eFng=";
                  })
                ];
              }).overrideAttrs # This overrideAttrs will go away once <https://github.com/NixOS/nixpkgs/pull/434135> lands.
                (oldAttrs: {
                  nativeBuildInputs = oldAttrs.nativeBuildInputs ++ [
                    pkgs.xxd # Talk to jared about upstreaming this.
                  ];
                });
          in
          [
            "BL33=${uboot-mt7988_bpir4_emmc}/u-boot.bin"
            "BOOT_DEVICE=spim-nand"
            "DRAM_USER_DDR4=1"
            "USE_MKIMAGE=1"
            "all"
            "fip"
          ];
        patches = [ ../patches/extra-include.patch ]; # <<< eh? >>>
      }).overrideAttrs
        (oldAttrs: {
          nativeBuildInputs = oldAttrs.nativeBuildInputs ++ [
            pkgs.dtc # <<<
            pkgs.ubootTools # <<<
          ];
        });
  };
}
