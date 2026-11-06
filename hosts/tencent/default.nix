inputs@{ nixpkgs, disko, ... }:

nixpkgs.lib.nixosSystem {
  specialArgs = inputs;
  modules = [
    { nixpkgs.hostPlatform = inputs.system; }
    disko.nixosModules.disko
    ../../modules/sops.nix
    ./configuration.nix
    ./disko.nix
  ];
}
