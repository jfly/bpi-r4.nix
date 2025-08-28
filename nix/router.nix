{ inputs, ... }:
{
  flake.nixosConfigurations."bpir4" = inputs.nixpkgs.lib.nixosSystem {
    modules = [ ../bpir4/configuration.nix ];
    specialArgs = {
      inherit inputs;
    };
  };
}
