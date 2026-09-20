# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{
  config,
  pkgs,
  ...
}:

{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ../../modules/programs/obsidian-overlay.nix
  ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "aorus-nixos"; # Define your hostname.
  # Pick only one of the below networking options.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  networking.networkmanager.enable = true; # Easiest to use and most distros use this by default.

  # Set your time zone.
  time.timeZone = "Asia/Shanghai";

  # Configure network proxy if necessary
  networking.proxy = {
    # default = "socks5h://192.168.2.10:7890";
    default = "http://127.0.0.1:7890";
    # allProxy = "http://192.168.2.52:7890";
  };
  networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain,192.168.2.0/24";

  services.earlyoom.enable = true;
  # 全量 Magic SysRq：桌面冻死时 Alt+SysRq+F 手动杀最大进程，REISUB 安全重启
  boot.kernel.sysctl."kernel.sysrq" = 1;
  services.openssh.enable = true;

  # i18n.inputMethod = {
  #   enable = true;
  #   type = "fcitx5";
  #   fcitx5.addons = with pkgs; [
  #     fcitx5-rime
  #     fcitx5-gtk
  #   ];
  # };
  # Select internationalisation properties.
  # i18n.defaultLocale = "en_US.UTF-8";
  # console = {
  #   font = "Lat2-Terminus16";
  #   keyMap = "us";
  #   useXkbConfig = true; # use xkb.options in tty.
  # };

  # Enable the X11 windowing system.
  services.xserver.enable = true;
  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;
  # programs.niri.enable = true;

  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.graphics.enable = true;
  hardware.nvidia.open = true;
  hardware.nvidia.modesetting.enable = true;
  # 挂起/休眠支持：设置 NVreg_PreserveVideoMemoryAllocations=1，并在休眠前后
  # 保存/恢复显存快照（写入 /var/tmp），否则 NVIDIA + Wayland 唤醒易黑屏花屏
  hardware.nvidia.powerManagement.enable = true;
  nixpkgs.config = {
    allowUnfree = true;
    # CUDA 构建只编本机 GPU 的架构（4070 Ti SUPER = Ada, sm_8.9）；
    # 不收窄的话 nixpkgs 默认编 9 种架构，nvcc 阶段能慢好几倍
    cudaCapabilities = [ "8.9" ];
    cudaForwardCompat = false;
  };

  fonts = {
    packages = with pkgs; [
      jetbrains-mono
      noto-fonts-color-emoji
      lxgw-wenkai
      wqy_microhei
      nerd-fonts.jetbrains-mono
    ];
  };

  # Configure keymap in X11
  # services.xserver.xkb.layout = "us";
  # services.xserver.xkb.options = "eurosign:e,caps:escape";

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable sound.
  # hardware.pulseaudio.enable = true;
  # OR
  # services.pipewire = {
  #   enable = true;
  #   pulse.enable = true;
  # };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.mutableUsers = false;
  users.users = {
    root.hashedPasswordFile = config.sops.secrets.hashedPassword.path;

    azurice = {
      hashedPasswordFile = config.sops.secrets.hashedPassword.path;
      isNormalUser = true;
      extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
      packages = with pkgs; [
        # firefox
        # inputs.firefox.packages.${pkgs.stdenv.hostPlatform.system}.firefox-nightly-bin
        # WebGPU：Dawn 直接加载 Vulkan，与 Chromium 合成器无关。
        # Dawn 有独立的 adapter blocklist（默认拒绝新 NVIDIA 驱动），
        # 用 disable_adapter_blocklist 精准解封，比 --ignore-gpu-blocklist 影响面小
        (vivaldi.override {
          commandLineArgs = "--enable-unsafe-webgpu --enable-dawn-features=disable_adapter_blocklist";
        })
        # wlx-overlay-s
        gamescope
        python3 # for ai simple use
      ];
      shell = pkgs.zsh;
    };
  };
  programs.zsh.enable = true;

  programs.localsend = {
    enable = true;
    openFirewall = true;
  };

  programs.clash-verge = {
    # package = pkgs.clash-nyanpasu;
    package = pkgs.clash-verge-rev;
    enable = true;
    tunMode = true;
    serviceMode = true;
    #   # autoStart = true;
  };

  services.udev.extraRules = ''
    SUBSYSTEM=="usb", ATTRS{idVendor}=="2207", ATTRS{idProduct}=="320a", MODE="0666"
    SUBSYSTEM=="usb", ATTRS{idVendor}=="2207", ATTRS{idProduct}=="320b", MODE="0666"
  '';

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    git
    neovim
    helix

    # btop
    (pkgs.btop.overrideAttrs (old: {
      nativeBuildInputs = (old.nativeBuildInputs or [ ]) ++ [ pkgs.makeWrapper ];
      postFixup = ''
        wrapProgram $out/bin/btop \
          --prefix LD_LIBRARY_PATH : /run/opengl-driver/lib
      '';
    }))
    just
  ];

  environment.etc = {
    # setting ssh file at this point is also not early enough for sops to load, so just use bind mount instead
    # see hardware-configuration.nix
    # "ssh/ssh_host_ed25519_key".source = "/persist/etc/ssh/ssh_host_ed25519_key";
    # "ssh/ssh_host_ed25519_key.pub".source = "/persist/etc/ssh/ssh_host_ed25519_key.pub";
    # "ssh/ssh_host_rsa_key".source = "/persist/etc/ssh/ssh_host_rsa_key";
    # "ssh/ssh_host_rsa_key.pub".source = "/persist/etc/ssh/ssh_host_rsa_key.pub";
    machine-id.source = "/persist/etc/machine-id";
  };

  # machine-id 持久化（血泪教训，勿乱改）：
  # - /etc/machine-id 通过上面的 environment.etc 软链到 /persist/etc/machine-id。
  # - 不要改用 bind mount：源文件缺失时挂载直接失败，可能导致无法开机；
  #   symlink 缺失文件时只会降级为当次随机 id，系统照常启动。
  # - 不要指望 systemd-machine-id-commit 自动写盘：systemd >= 258 的 commit
  #   路径拒绝跟随 symlink（O_NOFOLLOW），会静默空转，见
  #   https://github.com/systemd/systemd/issues/39717
  # - 因此用这个 activation 脚本自愈，每次 boot / nixos-rebuild 都会运行：
  #   a) 文件被 systemd 的临时 tmpfs 遮挡（说明磁盘文件缺失/为空）：记下
  #      当前 id，卸载遮挡后写回真实文件——相当于替 machine-id-commit 完成
  #      它在 symlink 下做不了的提交，本次启动内即可恢复；
  #   b) 文件缺失或为空且未被遮挡：直接生成合法 id 写入（PID1 读
  #      machine-id 早于 activation，这种情况下次启动生效）。
  #   最坏情况只是某次启动临时用一次随机 id，永远不会导致无法开机。
  system.activationScripts.persistMachineId.text = ''
    f=/persist/etc/machine-id
    if ${pkgs.util-linux}/bin/findmnt -n -M "$f" > /dev/null 2>&1; then
      id=$(cat /etc/machine-id)
      if ${pkgs.util-linux}/bin/umount "$f"; then
        mkdir -p /persist/etc
        printf '%s\n' "$id" > "$f.tmp"
        chmod 444 "$f.tmp"
        mv "$f.tmp" "$f"
      else
        echo "persistMachineId: failed to umount $f, will retry on next activation" >&2
      fi
    elif [ ! -s "$f" ]; then
      mkdir -p /persist/etc
      tr -d -- - < /proc/sys/kernel/random/uuid > "$f.tmp"
      chmod 444 "$f.tmp"
      mv "$f.tmp" "$f"
    fi
  '';

  # On this host the SSH host keys live under /persist/etc/ssh only (no bind
  # mount to /etc/ssh), so restrict sops-nix to the path that actually exists.
  sops.age.sshKeyPaths = [ "/persist/etc/ssh/ssh_host_ed25519_key" ];
  # Impermanence with sops-nix to may cause bad things to happen
  # see: https://github.com/nix-community/impermanence/issues/202
  # environment.persistence."/persistent" = {
  #   enable = true;
  #   # hideMounts = true;
  #   directories = [
  #     "/var/log"
  #     "/var/lib/bluetooth"
  #     "/var/lib/nixos"
  #     "/var/lib/sops-nix"
  #     "/var/lib/systemd/coredump"
  #     "/etc/NetworkManager/system-connections"
  #     "/etc/ssh"
  #   ];
  #   files = [
  #     "/etc/machine-id"
  #   ];
  #   users.azurice = {
  #     directories = [
  #       "Downloads"
  #       { directory = ".gnupg"; mode = "0700"; }
  #       { directory = ".ssh"; mode = "0700"; }
  #     ];
  #   };
  # };

  nix = {
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
    settings = {
      substituters = [
        "https://hyprland.cachix.org"
        "https://mirrors.bfsu.edu.cn/nix-channels/store"
      ];
      trusted-substituters = [
        "https://hyprland.cachix.org"
      ];
      trusted-public-keys = [ "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc=" ];
    };
  };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # CharaForge 本地角色扮演应用（手机经局域网访问）
  networking.firewall.allowedTCPPorts = [ 3000 ];
  # Palworld dedicated server: 8211 游戏端口(直接 IP 加入只需这个;27015 为社区列表查询端口,需要时再加)
  networking.firewall.allowedUDPPorts = [ 8211 ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system - see https://nixos.org/manual/nixos/stable/#sec-upgrading for how
  # to actually do that.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "24.11"; # Did you read the comment?

}
