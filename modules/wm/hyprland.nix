inputs@{ lib, pkgs, user, ... }:
{
  programs.hyprland = {
    enable = true;
    package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
    portalPackage = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland;
  };

  programs.xwayland.enable = lib.mkForce true;

  # 为 Noctalia / ddcutil 提供外接显示器 DDC/CI 亮度控制
  hardware.i2c.enable = true;
  users.users.${user}.extraGroups = [ "i2c" ];
}
