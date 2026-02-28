{
  description = "My personal flakes";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    nixos-wsl.url = "github:nix-community/NixOS-WSL/main";
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
    chromium-darwin.url = "github:lrworth/chromium-bin-flake";
    # flake.nix
    paneru = {
      url = "github:karinushka/paneru";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{ self, ... }:
    let
      host-inputs = inputs // {
        user = "azurice";
      };
    in
    {

      nixosConfigurations.aorus-nixos = import ./hosts/aorus-nixos (
        host-inputs
        // {
          system = "x86_64-linux";
          mac = false;
        }
      );

      nixosConfigurations.nixos-wsl = import ./hosts/nixos-wsl (
        host-inputs
        // {
          system = "x86_64-linux";
          mac = false;
        }
      );

      nixosConfigurations.azurblade = import ./hosts/azurblade (
        host-inputs
        // {
          system = "x86_64-linux";
          mac = false;
        }
      );

      darwinConfigurations.azurmac-macos = import ./hosts/azurmac-macos (
        host-inputs
        // {
          system = "aarch64-darwin";
          mac = true;
        }
      );

      darwinConfigurations.azur-macmini = import ./hosts/azur-macmini (
        host-inputs
        // {
          system = "aarch64-darwin";
          mac = true;
        }
      );
    }
    // inputs.flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = inputs.nixpkgs.legacyPackages.${system};
        lib = inputs.nixpkgs.lib;
      in
      {
        packages.cc-switch = import ./packages/cc-switch.nix {
          inherit lib;
          inherit (pkgs) stdenvNoCC fetchurl unzip;
        };
        packages.splitrail = import ./packages/splitrail.nix {
          inherit lib;
          inherit (pkgs) stdenvNoCC fetchurl unzip;
        };

        devShells.default = pkgs.mkShell {
          packages = with pkgs; [
            sops
            ssh-to-age
            age
          ];
        };
      }
    );
}
