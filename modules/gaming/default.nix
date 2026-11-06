{ pkgs, ... }:

let
  # 单独固定新版 GE-Proton，不为此更新整套 nixpkgs。
  geProton = pkgs.proton-ge-bin.overrideAttrs (_: {
    version = "GE-Proton11-12";
    toolName = "GE-Proton11-12-x86_64";
    steamDisplayName = "GE-Proton11-12";
    src = pkgs.fetchzip {
      url = "https://github.com/GloriousEggroll/proton-ge-custom/releases/download/GE-Proton11-12/GE-Proton11-12-x86_64.tar.gz";
      hash = "sha256-i20g9lDz7bR0SXWmvHZHztN4m8AHkcD0/OVGSC4ZzI8=";
    };
  });
in
{
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
    extraCompatPackages = with pkgs; [
      geProton
      dwproton-bin
    ];
  };

  # Wine（nixpkgs staging，wow64）：跑 FFXIV 用，比 XIVLauncher 托管的 wine-xiv 8.5 新得多
  # umu-launcher：Steam 之外跑 Windows 游戏/启动器（umu-run），前缀在 ~/Games/umu/<GAMEID>
  environment.systemPackages = [
    pkgs.wineWow64Packages.staging
    pkgs.umu-launcher
  ];

  # ntsync：内核 6.14+ 的同步原语，wine 10+ 原生支持（帧 pacing 比 esync/fsync 稳）
  # /dev/ntsync 自 6.14（及 6.13.11 回补）起默认 0666，无需额外 udev 规则
  boot.kernelModules = [ "ntsync" ];

  # 32 位图形驱动（steam 通常已隐含开启，显式声明以保 wine 32 位组件可用）
  hardware.graphics.enable32Bit = true;
  services.wivrn = {
    enable = true;
    openFirewall = true;
    highPriority = true;

    # NVIDIA 硬件编码
    package = pkgs.wivrn.override {
      cudaSupport = true;
    };

    # 让 Steam 的运行容器找到 OpenXR runtime
    steam.importOXRRuntimes = true;
  };
  # programs.alvr = {
  #   package = (pkgs.callPackage ../../packages/alvr-nightly.nix { } );
  #   enable = true;
  #   openFirewall = true;
  # };
}
