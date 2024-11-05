{
  description = "My personal flakes";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    # impermanence.url = "github:nix-community/impermanence";
    sops-nix.url = "github:Mic92/sops-nix";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ self, nixpkgs, ... }: let
    host-inputs = inputs // { user = "azurice"; };
  in {

    nixosConfigurations.aorus-nixos = import ./hosts/aorus-nixos host-inputs;

  };
}
