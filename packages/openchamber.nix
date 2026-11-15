# OpenChamber：server CLI 与 Electron 桌面版，构建及依赖使用上游 flake。
# Electron 单独取本 flake 的 nixpkgs，保证其 glibc 能加载系统 Mesa 驱动；
# 大版本遵循上游 package.json，确保 API 和 node-pty ABI 匹配。
{
  inputs,
  system ? "x86_64-linux",
}:

let
  upstream = inputs.openchamber;
  pkgs = inputs.nixpkgs.legacyPackages.${system};
  electronSpec =
    (builtins.fromJSON (builtins.readFile "${upstream}/packages/electron/package.json"))
    .devDependencies.electron;
  electronMajor = pkgs.lib.versions.major (pkgs.lib.removePrefix "^" electronSpec);

  # OpenCode 2.2.6 的 packages/cli/script/build.ts 用 ws-named-reexports 插件把
  # 上游 `export * from "ws"` 换成具名导出：
  #   { createWebSocketStream, extension, Receiver, Sender, subprotocol, WebSocket,
  #     WebSocketServer } from "ws"
  # Bun 把 "ws" 解析成内建的 ws 实现（不打进 bundle），而内建 ws 只有 bun >= 1.4.4
  # 才有 extension / subprotocol 这两个导出。上游 flake 自带 nixpkgs 里是 bun 1.4.2，
  # 编出来的 `opencode serve` 一启动就 `SyntaxError: Export named 'extension' not
  # found in module 'ws'`，OpenChamber 便没有后端：会话刷新、模型列表全拉不到
  # （Electron 日志里的 "Failed to start OpenCode ... code 1"）。
  # 这里只把编译期的 bun 换成本 flake nixpkgs 里的 1.4.4；node_modules 的 FOD 不动，
  # 否则它的 outputHash 对不上。
  opencodeCli = upstream.packages.${system}.opencode-cli.overrideAttrs (old: {
    nativeBuildInputs = map (p: if (p.pname or "") == "bun" then pkgs.bun else p) (
      old.nativeBuildInputs or [ ]
    );
  });
in
{
  inherit opencodeCli;
  openchamber = upstream.packages.${system}.openchamber.override { inherit opencodeCli; };
  openchamber-desktop = upstream.packages.${system}.openchamber-desktop.override {
    inherit opencodeCli;
    electron = pkgs."electron_${electronMajor}";
  };
}
