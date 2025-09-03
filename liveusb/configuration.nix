{
  self,
  self',
  modulesPath,
  pkgs,
  ...
}:

let
  uboot-nand = self'.packages.uboot-uart.override {
    uartBoot = false;
    combined = true;
  };
in
{
  imports = [
    self.nixosModules.default
    "${modulesPath}/installer/cd-dvd/installation-cd-minimal.nix"
  ];

  environment.systemPackages = [
    pkgs.mtdutils
    (pkgs.writeShellApplication {
      name = "bpi-r4-flash-nand";
      runtimeInputs = with pkgs; [
        mtdutils
      ];
      text = ''
        if [ $# -eq 0 ]; then
          echo "Please specify a MTD device. Run 'mtdinfo' to get a list of MTD devices."
          exit 1
        fi

        mtd_device=$1

        sudo flashcp --verbose "${uboot-nand}" "/dev/$mtd_device"
      '';
    })
  ];

  nixpkgs.hostPlatform.system = "aarch64-linux";

  boot = {
    initrd.systemd.enable = true;
    growPartition = true;
    consoleLogLevel = 7;
  };

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-label/nixos";
      fsType = "ext4";
      options = [ "noatime" ];
    };
  };

  # We need a pretty new kernel, which usually doesn't play nicely with
  # ZFS.
  boot.supportedFilesystems.zfs = false;
}
