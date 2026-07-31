# NixOS-only additions to core.nix (imported by NixOS hosts only)
{
  services.gnome.gnome-keyring.enable = true;

  programs.nix-ld.enable = true;
}
