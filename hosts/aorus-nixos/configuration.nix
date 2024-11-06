# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

inputs@{ config, lib, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ../../modules/core.nix
    ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "aorus-nixos"; # Define your hostname.
  # Pick only one of the below networking options.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  networking.networkmanager.enable = true;  # Easiest to use and most distros use this by default.

  # Set your time zone.
  time.timeZone = "Asia/Shanghai";

  # Configure network proxy if necessary
  networking.proxy = {
    default = "socks5h://192.168.2.10:7890";
    # allProxy = "http://192.168.2.10:7890";
  };
  networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  # i18n.defaultLocale = "en_US.UTF-8";
  # console = {
  #   font = "Lat2-Terminus16";
  #   keyMap = "us";
  #   useXkbConfig = true; # use xkb.options in tty.
  # };

  # Enable the X11 windowing system.
  services.xserver.enable = true;
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;
  programs.niri.enable = true;

  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.nvidia.open = true;
  nixpkgs.config.allowUnfree = true;

  
  fonts = {
    packages = with pkgs; [
      jetbrains-mono
      nerdfonts
      noto-fonts-emoji
      lxgw-wenkai
      wqy_microhei
      (nerdfonts.override { fonts = [ "JetBrainsMono" ]; })
    ];
    fontconfig.hinting.autohint = true;
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
    # root.hashedPassword = "$y$j9T$gvNzucUE/k0tdgRMxiXyL.$hW/nKUAKUVcsmVSf8jbTejBGgerVIDKqtAh06iZKow3";

    azurice = {
      hashedPasswordFile = config.sops.secrets.hashedPassword.path;
      # hashedPassword = "$y$j9T$gvNzucUE/k0tdgRMxiXyL.$hW/nKUAKUVcsmVSf8jbTejBGgerVIDKqtAh06iZKow3";
      isNormalUser = true;
      extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
      packages = with pkgs; [
        # firefox
        inputs.firefox.packages.${pkgs.system}.firefox-nightly-bin

        alacritty

        rust-analyzer
        nil
        nixpkgs-fmt
      ];
    };
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    git
    neovim
    helix

    btop
    just
  ];

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
  #     # "/etc/machine-id"
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
    settings.substituters = [
      "https://hyprland.cachix.org"
      "https://mirrors.bfsu.edu.cn/nix-channels/store"
    ];
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
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
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
  system.stateVersion = "24.05"; # Did you read the comment?

}

