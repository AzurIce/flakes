inputs@{ user, nixpkgs, sops-nix, home-manager, ... }:

nixpkgs.lib.nixosSystem {
  system = inputs.system;
  specialArgs = inputs;
  modules = [
    ./configuration.nix
    ../../modules/core.nix
    # ../../modules/gaming
    ../../modules/wm/hyprland.nix
    # impermanence.nixosModules.impermanence
    sops-nix.nixosModules.sops
    home-manager.nixosModules.home-manager {
      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;
      home-manager.extraSpecialArgs = inputs;
      home-manager.users.${user} = import ./home.nix;
    }
  ];
}
