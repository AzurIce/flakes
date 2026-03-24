
{ pkgs, lib, nix-openclaw, ... }:

{
  # enable flakes globally
  nix.settings = {
    extra-substituters = [
      # Query the mirror of USTC first, and then the official cache.
      "https://mirrors.ustc.edu.cn/nix-channels/store"
    ];
    trusted-substituters = [
      "https://mirrors.ustc.edu.cn/nix-channels/store"
    ];
    experimental-features = [ "nix-command" "flakes" ];
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Allow insecure openclaw package
  nixpkgs.config.permittedInsecurePackages = [
    "openclaw-2026.3.12"
  ];

  # Add nix-openclaw overlay
  nixpkgs.overlays = [
    nix-openclaw.overlays.default
  ];

  # Auto upgrade nix package and the daemon service.
  # services.nix-daemon.enable = true;

  # nix.package = pkgs.nix;
  nix.package = pkgs.nixVersions.latest;
  programs.nix-index.enable = true;

  nix.gc = {
    automatic = lib.mkDefault true;
    options = lib.mkDefault "--delete-older-than 7d";
  };

  nix.settings = {
    auto-optimise-store = false;
  };
}
