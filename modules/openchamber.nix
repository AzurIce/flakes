# OpenChamber —— OpenCode 的 Web UI（openchamber/openchamber）
# 目前用桌面版（Electron，见 hosts/aorus-nixos/home.nix 的 home.packages），server 内嵌在
# Electron 主进程里，因此这里保持关闭，避免两个 server 抢 3000 端口。
# 想切回服务模式（systemd 常驻 + 浏览器访问 http://127.0.0.1:3000）：enable 改 true，
# 并把 home.nix 里的 openchamber-desktop 删掉。
# 服务内部 spawn 的 opencode 是上游 pin 的版本（配套 UI），与 home/ai 里的 CLI 互不冲突，
# 共用 ~/.config/opencode
{ inputs, pkgs, ... }:
{
  services.openchamber = {
    enable = false;
    # 用本 flake 重烤过 bunDeps 哈希的 server 包；上游默认包会 hash mismatch，
    # 见 packages/openchamber.nix
    package = inputs.self.packages.${pkgs.stdenv.hostPlatform.system}.openchamber;
    # user = "azurice"; # 以本人身份跑，能直接看到我的项目 / SSH key / opencode 配置
  };
}
