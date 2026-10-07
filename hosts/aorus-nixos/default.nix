inputs@{
  user,
  nixpkgs,
  home-manager,
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
