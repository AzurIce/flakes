{ user, ... }:

{
  imports = [
    ../../home/wm/hyprland
    ../../home/programs/eww

    ../../home/programs/git.nix
    ../../home/programs/helix.nix
    ../../home/programs/waybar
  ];

  home = {
    username = "${user}";
    homeDirectory = "/home/${user}";
    stateVersion = "24.05";
  };

  programs.home-manager.enable = true;
  manual.manpages.enable = false;
}
