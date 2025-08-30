{
  self,
  ...
}:
{
  imports = [ self.nixosModules.default ];

  system.stateVersion = "25.11";
  nixpkgs.hostPlatform.system = "aarch64-linux";

  networking.hostName = "bpir4-example";

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

  # Access
  services.openssh.enable = true;
  users.users.root = {
    password = "passpass";
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIImw0Xc1buEQ9WOskyGGeg3QwdbU7DTUQBiu02fObDlm" # https://github.com/jfly.keys
    ];
  };
}
