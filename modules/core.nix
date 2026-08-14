inputs@{ pkgs, lib, ... }:

{
  nixpkgs.overlays = [
    inputs.claude-code.overlays.default
    inputs.codex-cli.overlays.default

    # ⚠️ TODO: 这是临时 workaround，nixpkgs 修了之后记得删掉 ⚠️
    #
    # 原因：nixos-unstable 0e251e2（2026-08-13）里 python313Packages.nanoemoji 的
    # 源码 hash 过期（GitHub tarball 变了），导致 jetbrains-mono
    # （→ python313Packages.gftools → nanoemoji）构建失败，并级联挂掉整个系统 build。
    # 上游修复 commit：1e544d5f "python3Packages.nanoemoji: fix hash"（只在 master）。
    #
    # 删除时机：下次 nix flake update 后，如果 nixpkgs rev 已包含 1e544d5f
    # （检查：nix flake metadata nixpkgs 或 grep 1e544d5f flake.lock），
    # 且 `nix build nixpkgs#python313Packages.nanoemoji` 不再报 hash mismatch，即可删掉下面这段。
    (final: prev: {
      python313Packages = prev.python313Packages.overrideScope (pyFinal: pyPrev: {
        nanoemoji = pyPrev.nanoemoji.overrideAttrs (old: {
          src = old.src.override { hash = "sha256-FysyKC01XBnRiur5RR9fcsTxQqE8x0JJHSoe3q6JtKc="; };
        });
      });
    })
  ];

  nix.settings = {
    extra-substituters = [
      "https://mirror.sjtu.edu.cn/nix-channels/store"
      "https://nix-community.cachix.org"
      "https://noctalia.cachix.org"
    ];

    trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "noctalia.cachix.org-1:pCOR47nnMEo5thcxNDtzWpOxNFQsBRglJzxWPp3dkU4="
    ];
  };

  environment.systemPackages = [ pkgs.nh ];
}
