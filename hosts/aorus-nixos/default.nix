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
    ../../modules/sops.nix
    ../../modules/audio.nix
    ../../modules/bluetooth.nix
    # ../../modules/gaming
    ../../modules/wm/hyprland.nix
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
