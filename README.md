# bpi-r4.nix

This is mostly lift and shift from <https://gitlab.com/K900/nix>.

## Bootstrapping a new board

Connect your BPI R4 via UART. Run `nix run .#flash-uart -- --serial <device>`
(substituting your serial device) and wait for the "Handshake..." message:

```console
$ nix run .#flash-uart -- --serial /dev/ttyUSB0
mtk_uartboot - 0.1.1
Using serial port: /dev/ttyUSB0
Handshake...
```

Now reboot your BPI R4:

```console
$ nix run .#flash-uart -- --serial /dev/ttyUSB0
...
hw code: 0x7988
hw sub code: 0x8a00
hw ver: 0xcb00
sw ver: 0x1
Baud rate set to 460800
sending payload to 0x201000...
Checksum: 0xb318
Setting baudrate back to 115200
Jumping to 0x201000 in aarch64...
Waiting for BL2. Message below:
==================================
NOTICE:  BL2: v2.12.0(release):
NOTICE:  BL2: Built : 00:00:00, Jan  1 1980
NOTICE:  WDT: Cold boot
NOTICE:  WDT: disabled
NOTICE:  CPU: MT7988
NOTICE:  EMI: Using DDR unknown settings
NOTICE:  EMI: Detected DRAM size: 4096 MB
NOTICE:  EMI: complex R/W mem test passed
NOTICE:  LVTS: Enable thermal HW reset
NOTICE:  Starting UART download handshake ...
==================================
BL2 UART DL version: 0x10
Baudrate set to: 115200    # <--- This will hang for a while while transferring fib.bin --->
FIP sent.
==================================
NOTICE:  Received FIP 0x117841 @ 0x40400000 ...
==================================
```

Now connect to the UART. This should drop you into a U-Boot shell (you may have
to press enter to see anything):

```console
$ tio /dev/ttyUSB0
...
MT7988>
```

Build a live USB (`liveusb-cross` is a cross compiled version which might build
faster if you're on x86):

```console
$ nix build .#nixosConfigurations.liveusb-native.config.system.build.isoImage
$ sudo dd if=$(ls result/iso/nixos-minimal-*.iso) of=/dev/<DEVICE> status=progress
```

Plug the USB drive into your BPI R4, and boot it from
U-Boot. If you see multiple bootflows, select the
`usb_mass` one:

```console
MT7988> bootflow scan
Cannot persist EFI variables without system partition
scanning bus for devices...
...

MT7988> bootflow list
Showing all bootflows
Seq  Method       State   Uclass    Part  Name                      Filename
---  -----------  ------  --------  ----  ------------------------  ----------------
  0  extlinux     ready   mmc          1  mmc@11230000.bootdev.part /boot/extlinux/extlinux.conf
  1  efi          ready   usb_mass_    1  usb_mass_storage.lun0.boo /EFI/BOOT/BOOTAA64.EFI
---  -----------  ------  --------  ----  ------------------------  ----------------
(2 bootflows, 2 valid)

MT7988> bootflow select 1

MT7988> bootflow boot
** Booting bootflow 'usb_mass_storage.lun0.bootdev.part_1' with efi
Add 'ramoops@42ff0000' node failed: FDT_ERR_EXISTS
Booting /\EFI\BOOT\BOOTAA64.EFI

Loading graphical boot menu...

Press 't' to use the text boot menu on this console...

error: no suitable video mode found.

                         GNU GRUB  version 2.12
...

nixos login: nixos (automatic login)


[nixos@nixos:~]$
```

Now flash the NAND chip:

```console
[nixos@nixos:~]$ bpi-r4-flash-nand mtd0
Erasing blocks: 53/53 (100%)
Writing data: 6750k/6750k (100%)
Verifying data: 6750k/6750k (100%)
```

Flip the boot selection pin to NAND (0, 1) and reboot. You should boot back
into the live USB environment.

Proceed with installing NixOS as you usually do (see [NixOS
Module](#nixos-module)). I install my OS to the eMMC block device, however you
could boot from USB or SD card if you prefer.

## NixOS Module

This flake provides a NixOS module which sets up the correct kernel and
devicetree. Once this is upstreamed, we will change the module to throw
assertions.
