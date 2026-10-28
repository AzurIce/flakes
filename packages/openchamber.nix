# OpenChamber：server CLI（openchamber）与桌面版（Electron，server 内嵌在主进程里）。
#
# 上游 v2.5.2 的 nix/hashes.json 里 bunDeps（FOD 的 outputHash）与实际 registry
# 内容不符，直接用 inputs.openchamber 的包会在 bun install 阶段 hash mismatch；
# 这里先用 openchamber-bundeps-hash.patch 重烤哈希，再按上游 flake 的方式构建。
# 服务模式（modules/openchamber.nix）也用这里的 openchamber，避免踩同一个坑。
#
# 为什么是 IFD（callPackage "${patchedSrc}/nix/..."）而不是 getFlake：
#   outputHash 只在 eval 时从 nix/hashes.json 读，所以补丁必须在 eval 前生效；
#   但 applyPatches 的产物是 derivation，builtins.getFlake 只接受已存在的路径
#   （且拒绝带 context 的 store path），eval 时它还没构建出来。
#   callPackage 一个 derivation 内的 .nix 文件会触发 IFD：eval 先建出打过补丁的
#   源码树，再 import 其中的构建表达式。补丁只改数据文件，成本是几秒的本地构建。
#
# 依赖必须取 openchamber input 自带的 nixpkgs：FOD 哈希是对着它的 bun 版本烤的，
# 换成本 flake 的 nixpkgs 会再次 hash mismatch（见 flake.nix 的 openchamber 注释）。
#
# 唯一例外是 Electron：它取本 flake 的 nixpkgs。NixOS 上 Electron 运行时要 dlopen
# 系统 /run/opengl-driver 里的 mesa，而系统 mesa 是对着系统 glibc 编译的；用上游
# 自带（更旧）的 nixpkgs 时 Electron 链接的是 glibc 2.42，系统 mesa 26.2.5 要
# GLIBC_2.43，加载 DRI 驱动失败（MESA-LOADER: version `GLIBC_2.43' not found），
# 只能退化成软件渲染。上游 flake 只要求 electron 大版本匹配
# （packages/electron/package.json 的 ^44.9.0），本 flake 的 electron_44 是
# 44.9.3，正好落在范围内。
{
  inputs,
  system ? "x86_64-linux",
}:

let
  upstream = inputs.openchamber;
  pkgs = upstream.inputs.nixpkgs.legacyPackages.${system};
  hostPkgs = inputs.nixpkgs.legacyPackages.${system};
  lib = pkgs.lib;
  src = inputs.openchamber-src;

  version = (builtins.fromJSON (builtins.readFile "${src}/package.json")).version;

  patchedSrc = pkgs.applyPatches {
    name = "openchamber-${version}-rebaked";
    inherit src;
    patches = [ ./openchamber-bundeps-hash.patch ];
  };

  # 桌面版 bundle 的 OpenCode CLI 是上游 pin 的 2.x（nixpkgs 里的 opencode 是 1.x）
  opencodeCli = upstream.packages.${system}.opencode-cli;

  core = pkgs.callPackage "${patchedSrc}/nix/package.nix" {
    self = patchedSrc;
    inherit version opencodeCli;
  };

  # 大版本推导与上游一致（Electron 大版本决定 node-pty 的头文件/ABI）；
  # 包本身取本 flake 的 nixpkgs，理由见文件头。
  electronMajor =
    let
      spec = (builtins.fromJSON (builtins.readFile "${src}/packages/electron/package.json"))
        .devDependencies.electron;
    in
    lib.versions.major (lib.removePrefix "^" spec);
  electron = hostPkgs."electron_${electronMajor}";
in
{
  # 服务模式：systemd 常驻 + 浏览器访问
  openchamber = core;

  # 桌面版：Electron GUI，server 内嵌在主进程里
  openchamber-desktop = pkgs.callPackage "${patchedSrc}/nix/gui.nix" {
    self = patchedSrc;
    inherit version electron opencodeCli;
    src = core.passthru.src;
    openchamberCore = core.passthru.core;
  };
}
