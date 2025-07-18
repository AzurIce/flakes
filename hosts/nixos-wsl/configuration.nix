# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

# NixOS-WSL specific options are documented on the NixOS-WSL repository:
# https://github.com/nix-community/NixOS-WSL

{ user, config, lib, pkgs, ... }:

{
  imports = [];

  wsl.enable = true;
  wsl.defaultUser = "${user}";

  networking = {
    hostName = "nixos-wsl";
    proxy = {
      default = "socks5h://127.0.0.1:7890";
      allProxy = "socks5h://127.0.0.1:7890";
    };
  };

  environment.systemPackages = with pkgs; [
    eza
    git
    helix
    btop

    just
    ffmpeg
    fzf
    yazi

    rust-analyzer
    nil
    nixpkgs-fmt
    poetry
    bun
    nodejs_22
    nodePackages_latest.pnpm
    typst
    sqlite
    pandoc
    python3
    cargo
    lua51Packages.luarocks
    lua51Packages.lua
    jdk21
    aria2
  ];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It's perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.11"; # Did you read the comment?
}
