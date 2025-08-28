# bpir4

## Build firmware

```console
$ nix build .#nixosConfigurations.bpir4.config.system.build.bpir4-firmware
```

## In u-boot (from openwrt)

```console
MT7988> usb start
starting USB...
Bus xhci@11200000: xhci-mtk xhci@11200000: hcd: 0x0000000011200000, ippc: 0x0000000011203e00
xhci-mtk xhci@11200000: ports disabled mask: u3p-0x0, u2p-0x0
xhci-mtk xhci@11200000: u2p:1, u3p:1
Register 200010f NbrPorts 2
Starting the controller
USB XHCI 1.10
scanning bus xhci@11200000 for devices... 5 USB Device(s) found
       scanning usb for storage devices... 1 Storage Device(s) found

MT7988> ls usb 0
            .Spotlight-V100/
            .fseventsd/
            .Trashes/
            .TemporaryItems/
   259232   bl2.img
  1150524   fip.bin

2 file(s), 4 dir(s)

MT7988> load usb 0 $loadaddr bl2.img
259232 bytes read in 5 ms (49.4 MiB/s)


# Offsets from u-boot::arch/arm/dts/mt7988a-bananapi-bpi-r4.dtsi

MT7988> mtd write spi-nand0 $loadaddr 0 0x200000
Writing 2097152 byte(s) (1024 page(s)) at offset 0x00000000



MT7988> load usb 0 $loadaddr fip.bin
259232 bytes read in 5 ms (49.4 MiB/s)

MT7988> mtd write spi-nand0 $loadaddr 0 0x580000
Writing 2097152 byte(s) (1024 page(s)) at offset 0x00000000
```

## k900's uboot

```
$ nix eval .#nixosConfigurations.bananya.config.system.build.uboot
$ sudo cp result/uboot.img /mnt/misc/

# connect usb to board, boot to uboot via sd card

MT7988> usb start
MT7988> load usb 0 $loadaddr uboot.img
6912065 bytes read in 51 ms (129.3 MiB/s)

# omfg
MT7988> mtd erase spi-nand0
Erasing 0x00000000 ... 0x07ffffff (1024 eraseblock(s))

MT7988> mtd write spi-nand0 $loadaddr 0 $filesize
Size not on a page boundary (0x800), rounding to 0x698000
Writing 6914048 byte(s) (3376 page(s)) at offset 0x00000000


```

## Build OS

```console
$ nix build .#nixosConfigurations.bpir4.config.system.build.images.sd-card
```


## booting

```console
[   14.454215] platform regulatory.0: Direct firmware load for regulatory.db failed with error -2
[   14.462880] cfg80211: failed to load regulatory.db
[  OK  ] Finished SSH Host Keys Generation.
         Starting SSH Daemon...
[  OK  ] Started SSH Daemon.
[   19.462521] fbcon: Taking over console


<<< Welcome to NixOS 25.11.20250825.3b9f00d (aarch64) - ttyS0 >>>

Run 'nixos-help' for the NixOS manual.

bpir4-jfly login: root
Password:

[root@bpir4-jfly:~]# [   33.760577] vproc: disabling
```
