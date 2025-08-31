{
  self,
  inputs,
  withSystem,
  ...
}:
let
  specialArgs = {
    inherit inputs self;
  };
  specialArgsModule = (
    { pkgs, ... }:
    {
      _module.args = {
        inputs' = withSystem pkgs.system ({ inputs', ... }: inputs');
        self' = withSystem pkgs.system ({ self', ... }: self');
      };
    }
  );
in
{
  flake.nixosConfigurations."bpi-r4-native" = inputs.nixpkgs.lib.nixosSystem {
    modules = [
      specialArgsModule
      ./configuration.nix
    ];
    inherit specialArgs;
  };

  flake.nixosConfigurations."bpi-r4-cross" = inputs.nixpkgs.lib.nixosSystem {
    modules = [
      specialArgsModule
      ./configuration.nix
      {
        nixpkgs.buildPlatform.system = "x86_64-linux";
      }
    ];
    inherit specialArgs;
  };
}
