{
  description = "My personal flakes";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    nixos-wsl = {
      url = "github:nix-community/NixOS-WSL/main";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    eza = {
      url = "github:eza-community/eza";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-darwin = {
      url = "github:lnl7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    neovim-nightly-overlay = {
      url = "github:nix-community/neovim-nightly-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # firefox = {
    #   url = "github:nix-community/flake-firefox-nightly";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };
    hyprland.url = "github:hyprwm/Hyprland";
    awww = {
      url = "git+https://codeberg.org/LGFae/awww";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    wayshot = {
      url = "github:waycrate/wayshot";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # hyprsession.url = "github:joshurtree/hyprsession";
    hyprcursor-phinger = {
      url = "github:jappie3/hyprcursor-phinger";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    chromium-darwin = {
      url = "github:lrworth/chromium-bin-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    paneru = {
      url = "github:karinushka/paneru";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.nix-darwin.follows = "nix-darwin";
    };
    claude-code = {
      url = "github:sadjow/claude-code-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    codex-cli = {
      url = "github:sadjow/codex-cli-nix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };
    nix-flatpak.url = "github:gmodena/nix-flatpak/?ref=latest";
    cc-statusline = {
      url = "github:AzurIce/cc-statusline";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };
    kimi-code = {
      url = "github:MoonshotAI/kimi-code";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    herdr = {
      url = "github:ogulcancelik/herdr";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    notist = {
      url = "github:AzurIce/notist";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };
    noctalia = {
      url = "github:noctalia-dev/noctalia-shell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{ self, ... }:
    let
      host-inputs = inputs // {
        user = "azurice";
        overlays = [
          inputs.claude-code.overlays.default
          inputs.codex-cli.overlays.default
        ];
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
        packages.revelo = import ./packages/revelo.nix {
          inherit lib;
          inherit (pkgs) stdenvNoCC fetchurl unzip;
        };
        packages.clipvault = import ./packages/clipvault.nix {
          inherit lib;
          inherit (pkgs) stdenv fetchurl autoPatchelfHook gcc;
        };
        packages.dsh = import ./packages/dsh.nix {
          inherit lib;
          inherit (pkgs) stdenv buildNpmPackage fetchzip nodejs_24 python3 jq;
        };

        devShells.default = pkgs.mkShell {
          packages = with pkgs; [
            nh
            sops
            ssh-to-age
            age
            # for packages/update.sh
            nodejs_24
            prefetch-npm-deps
          ];
        };
      }
    );
}
