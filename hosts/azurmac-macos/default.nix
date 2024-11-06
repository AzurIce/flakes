inputs@{ user, nixpkgs, home-manager, nix-darwin, ... }:

nix-darwin.lib.darwinSystem {
  system = inputs.system;
  specialArgs = inputs;
  modules = [
    ./nix-core.nix
    ./system.nix
    ./apps.nix
    ./host-users.nix
    # sops-nix.nixosModules.sops
    home-manager.darwinModules.home-manager {
      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;
      home-manager.extraSpecialArgs = inputs;
      home-manager.users.${user} = import ./home.nix;
    }
  ];
}