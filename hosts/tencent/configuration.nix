{ config, lib, pkgs, user, ... }:

{
  # BIOS + GPT: disko 建一个 1M EF02 BIOS boot 分区和根分区。
  # 如果这台机器实际是 UEFI，把 disko.nix 改成 ESP + systemd-boot。
  boot.loader.grub.enable = true;
  # disko 会根据 disk.main 自动设置 boot.loader.grub.devices；这里不要再设 device，
  # 否则会和 disko 的 mirroredBoots 重复。
  # boot.loader.grub.device = "/dev/vda";

  boot.initrd.availableKernelModules = [
    "virtio_pci"
    "virtio_blk"
    "virtio_net"
    "ahci"
    "sd_mod"
  ];
  boot.kernelModules = [ ];
  boot.extraModulePackages = [ ];
  boot.supportedFilesystems = [ "btrfs" ];
  boot.initrd.supportedFilesystems = [ "btrfs" ];

  networking.hostName = "tencent";
  networking.useDHCP = true;
  networking.firewall.allowedTCPPorts = [ 22 80 443 ];

  time.timeZone = "Asia/Shanghai";
  i18n.defaultLocale = "en_US.UTF-8";

  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      PermitRootLogin = "prohibit-password";
    };
  };

  users.mutableUsers = false;
  users.users.root = {
    hashedPasswordFile = config.sops.secrets.hashedPassword.path;
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPdDd1Nv4nuOU5jc1P+BTl+o78JkBGfDWTgKIRFsyc3j azurice@aorus-nixos"
    ];
  };
  users.users.${user} = {
    isNormalUser = true;
    hashedPasswordFile = config.sops.secrets.hashedPassword.path;
    extraGroups = [ "wheel" "docker" ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPdDd1Nv4nuOU5jc1P+BTl+o78JkBGfDWTgKIRFsyc3j azurice@aorus-nixos"
    ];
  };
  # 没有给用户设密码，先靠 key 登录；sudo 免密方便种子机使用。
  security.sudo.wheelNeedsPassword = false;

  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    substituters = [
      "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store"
      "https://mirrors.ustc.edu.cn/nix-channels/store"
      "https://cache.nixos.org"
    ];
    trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
    ];
    max-jobs = 1;
    cores = 2;
    auto-optimise-store = true;
  };
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 14d";
  };

  zramSwap.enable = true;
  virtualisation.docker.enable = true;
  services.caddy.enable = true;
  services.caddy.extraConfig = ''
    :80 {
      respond "tencent seed server" 200
    }
  '';

  environment.systemPackages = with pkgs; [
    git
    curl
    htop
    tmux
    vim
  ];

  system.stateVersion = "25.11";
}
