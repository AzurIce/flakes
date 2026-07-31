inputs@{ pkgs, lib, ... }:

{
  nixpkgs.overlays = [
    inputs.claude-code.overlays.default
    inputs.codex-cli.overlays.default
  ];

  nix.settings = {
    extra-substituters = [
      "https://mirror.sjtu.edu.cn/nix-channels/store"
      "https://nix-community.cachix.org"
    ];

    trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
  };

  environment.systemPackages = [ pkgs.nh ];
}
