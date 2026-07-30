inputs@{ pkgs, lib, ... }:

{
  nixpkgs.overlays = [
    inputs.claude-code.overlays.default
    inputs.codex-cli.overlays.default
    (final: prev: {
      clash-verge-rev =
        inputs.nixpkgs-clash-verge-rev-old.legacyPackages.${prev.stdenv.hostPlatform.system}.clash-verge-rev;
    })
    # (
    #   final: prev:
    #   lib.optionalAttrs prev.stdenv.isDarwin {
    #     # Workaround for zsh sigsuspend autoconf probe failure under C23 on Darwin,
    #     # which causes $(...) command substitutions to deadlock.
    #     # See: https://github.com/NixOS/nixpkgs/issues/513543
    #     zsh = prev.zsh.overrideAttrs (old: {
    #       preConfigure = (old.preConfigure or "") + ''
    #         export zsh_cv_sys_sigsuspend=yes
    #       '';
    #     });

    #     # Workaround for libfyaml generating bogus 'none required' link flags on Darwin,
    #     # which breaks downstream packages like appstream/libadwaita.
    #     # See: https://github.com/NixOS/nixpkgs/issues/514566
    #     libfyaml = prev.libfyaml.overrideAttrs (old: {
    #       patches = (old.patches or [ ]) ++ [
    #         (prev.fetchpatch {
    #           url = "https://github.com/pantoniou/libfyaml/commit/1026d76850909dc9b1c5f95b8cd94e865a313fd5.diff";
    #           hash = "sha256-0YfOqdqHdELFMqr52TDAC3BNFLkcuxvuJY5b9yZ7NFk=";
    #         })
    #         ./libfyaml-pthread-darwin.patch
    #         (prev.fetchpatch {
    #           url = "https://github.com/pantoniou/libfyaml/commit/24b18e7363b336962fe160c1dc05ca57ba95783c.diff";
    #           hash = "sha256-g5QKI4HuS8MEQ9ddIQNC0j+28Dh9zLAp5RaZX5SWBHk=";
    #         })
    #         (prev.fetchpatch {
    #           url = "https://github.com/pantoniou/libfyaml/commit/9f2492ca27bb1fda64f2b12edc2da17406208b93.diff";
    #           hash = "sha256-E4wS+P7R3VGrBpD7swWMMi/QPTF+9rzAeEyxhbmdiwk=";
    #         })
    #       ];
    #     });
    #   }
    # )
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
