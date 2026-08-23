# NixOS-only additions to core.nix (imported by NixOS hosts only)
{
  services.gnome.gnome-keyring.enable = true;

  programs.nix-ld.enable = true;

  nix = {
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 14d";
    };
    settings.auto-optimise-store = true;
  };
}
