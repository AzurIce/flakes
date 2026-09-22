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

    # ⚠️ 上游 workaround，xcb-imdkit 修复合入后记得删掉 ⚠️
    #
    # 原因：xcb-imdkit 1.0.9（上游最后一次发版，2024-05）的 XIM sync 模式有竞态：
    # XIM_DESTROY_IC 与在途 XIM_SYNC_REPLY 竞争时 client->sync 永不复位，之后该
    # 客户端所有按键进队列永不派发 → wine 游戏（FF14 等）随机"按键被吃"直到重启。
    # 上游 issue：https://github.com/fcitx/fcitx5/issues/1641（2026-08 定位，含本补丁）
    # 删除时机：xcb-imdkit 新 release 合入该修复后（检查 protocolhandler.c 的
    # _xcb_im_handle_sync_reply 不再对已销毁 IC 提前 break）。
    (final: prev: {
      xcb-imdkit = prev.xcb-imdkit.overrideAttrs (old: {
        patches = (old.patches or [ ]) ++ [
          ../patches/xcb-imdkit-xim-sync-freeze-fix.patch
        ];
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
