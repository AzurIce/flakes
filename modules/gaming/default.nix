{ pkgs, ... }:

{
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
  };

  # Wine（nixpkgs staging，wow64）：跑 FFXIV 用，比 XIVLauncher 托管的 wine-xiv 8.5 新得多
  environment.systemPackages = [ pkgs.wineWow64Packages.staging ];

  # ntsync：内核 6.14+ 的同步原语，wine 10+ 原生支持（帧 pacing 比 esync/fsync 稳）
  # /dev/ntsync 自 6.14（及 6.13.11 回补）起默认 0666，无需额外 udev 规则
  boot.kernelModules = [ "ntsync" ];

  # 32 位图形驱动（steam 通常已隐含开启，显式声明以保 wine 32 位组件可用）
  hardware.graphics.enable32Bit = true;
  # programs.alvr = {
  #   package = (pkgs.callPackage ../../packages/alvr-nightly.nix { } );
  #   enable = true;
  #   openFirewall = true;
  # };
}
