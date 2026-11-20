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

  # OpenCode 的 packages/cli/script/build.ts 用 ws-named-reexports 插件把上游
  # `export * from "ws"` 换成具名导出：
  #   { createWebSocketStream, extension, Receiver, Sender, subprotocol, WebSocket,
  #     WebSocketServer } from "ws"
  # Bun 把 "ws" 解析成内建的 ws 实现（不打进 bundle），而内建 ws 只有 bun >= 1.4.4
  # 才有 extension / subprotocol 这两个导出；用 1.4.2 编出来的 `opencode serve`
  # 一启动就 `SyntaxError: Export named 'extension' not found in module 'ws'`，
  # OpenChamber 便没有后端：会话刷新、模型列表全拉不到（Electron 日志里的
  # "Failed to start OpenCode ... code 1"）。
  # 2.7.3 起上游 flake 自带的 nixpkgs 也是 bun 1.4.4，这段目前是等价替换（只作
  # 兜底：上游的 nixpkgs follow 落后时仍能编出可用的 backend）。node_modules 的 FOD
  # 不动，否则它的 outputHash 对不上。
  opencodeCli = upstream.packages.${system}.opencode-cli.overrideAttrs (old: {
    nativeBuildInputs = map (p: if (p.pname or "") == "bun" then pkgs.bun else p) (
      old.nativeBuildInputs or [ ]
    );
  });
in
{
  inherit opencodeCli;
  openchamber = upstream.packages.${system}.openchamber.override { inherit opencodeCli; };
  # 2.7.3 起桌面版不再往 resources/opencode-cli 里塞 CLI，只靠 launcher 的 PATH
  # （gui.nix 的 runtimePath）找 opencode。但 server 启动时会拿 `$SHELL -lic` 的
  # 环境覆盖并前置 HOME 的 PATH（env-runtime.ts 的 applyLoginShellEnvSnapshot），
  # 于是 /etc/profiles/per-user/$USER/bin/opencode（本机 1.19.6）被选中，UI 卡在
  # “需要 OpenCode v2”。探测优先级里 OPENCODE_BINARY 最高，这里显式钉死自建的
  # 2.x，别再依赖 PATH 顺序（设置页里手动选路径仍会覆盖它）。
  openchamber-desktop =
    (upstream.packages.${system}.openchamber-desktop.override {
      inherit opencodeCli;
      electron = pkgs."electron_${electronMajor}";
    }).overrideAttrs
      (old: {
        # 该包 dontFixup = true，postFixup 不跑，只能接着 installPhase 再包一层。
        installPhase = (old.installPhase or "") + ''
          wrapProgram "$out/bin/openchamber-desktop" \
            --set OPENCODE_BINARY "${opencodeCli}/bin/opencode"
        '';
      });
}
