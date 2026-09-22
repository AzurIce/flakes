inputs@{
  user,
  nixpkgs,
  home-manager,
  nix-flatpak,
  ...
}:

nixpkgs.lib.nixosSystem {
  specialArgs = inputs;
  modules = [
    { nixpkgs.hostPlatform = inputs.system; }
    ./configuration.nix
    ../../modules/core.nix
    ../../modules/core-nixos.nix
    ../../modules/sops.nix
    ../../modules/audio.nix
    ../../modules/bluetooth.nix
    ../../modules/gaming
    ../../modules/wm/hyprland.nix
    ../../modules/programs/obs.nix
    # ComfyUI（MiniMax H3 本地推理）
    inputs.comfyui-nix.nixosModules.default
    ../../modules/comfyui.nix
    # impermanence.nixosModules.impermanence
    nix-flatpak.nixosModules.nix-flatpak
    {
      services.flatpak.enable = true;
      services.flatpak.remotes = [
        {
          name = "flathub";
          location = "https://dl.flathub.org/repo/flathub.flatpakrepo";
        }
      ];
      services.flatpak.packages = [
        {
          appId = "cn.ottercorp.xivlaunchercn";
          origin = "flathub";
        }
      ];
      # FF14（wine 跑在 flatpak 沙箱内）的输入法环境：wine 的 IME 走 XIM
      # （XIM 跑在 X 协议上，可穿透 flatpak 沙箱直达宿主 fcitx5），需要
      # fallback-x11 socket 和 XMODIFIERS；wine 自带的 GTK/SDL/QT IM 模块
      # 变量一并补齐。xcb-imdkit 的按键被吃 bug 已在 core.nix 里打补丁修复。
      # 注：此 rev 的 nix-flatpak 用 legacy 语法（无 .settings 包装）。
      services.flatpak.overrides."cn.ottercorp.xivlaunchercn" = {
        Context.sockets = [ "fallback-x11" ];
        Environment = {
          XMODIFIERS = "@im=fcitx";
          GTK_IM_MODULE = "fcitx";
          QT_IM_MODULE = "fcitx";
          SDL_IM_MODULE = "fcitx";
        };
      };
      systemd.services.flatpak-managed-install.environment = {
        http_proxy = "http://127.0.0.1:7890";
        https_proxy = "http://127.0.0.1:7890";
      };
    }
    home-manager.nixosModules.home-manager
    {
      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;
      home-manager.backupFileExtension = "backup";
      home-manager.extraSpecialArgs = inputs;
      home-manager.users.${user} = import ./home.nix;
      home-manager.sharedModules = [
        inputs.sops-nix.homeManagerModules.sops
      ];
    }
  ];
}
