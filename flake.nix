{
  description = "My personal flakes";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    chat.url = "github:YXHXianYu/chat";
    # nixpkgs.url = "github:nixos/nixpkgs/273673e839189c26130d48993d849a84199523e6";
    # impermanence.url = "github:nix-community/impermanence";
    sops-nix.url = "github:Mic92/sops-nix";

    eza = {
      url = "github:eza-community/eza";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-darwin = {
      url = "github:lnl7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    
    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";
    firefox = {
      url = "github:nix-community/flake-firefox-nightly";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hyprland.url = "github:hyprwm/Hyprland";
    hyprcursor-phinger.url = "github:jappie3/hyprcursor-phinger";
  };

  outputs = inputs@{ self, ... }: let
    host-inputs = inputs // { user = "azurice"; };
  in {

    nixosConfigurations.aorus-nixos = import ./hosts/aorus-nixos (
      host-inputs // {
        system = "x86_64-linux";
        mac = false;
      }
    );

    nixosConfigurations.azurblade = import ./hosts/azurblade (
      host-inputs // {
        system = "x86_64-linux";
        mac = false;
      }
    );

    darwinConfigurations.azurmac-macos = import ./hosts/azurmac-macos (
      host-inputs // {
        system = "aarch64-darwin";
        mac = true;
      }
    );

    darwinConfigurations.azur-macmini = import ./hosts/azur-macmini (
      host-inputs // {
        system = "aarch64-darwin";
        mac = true;
      }
    );

  };
}
