{ user, nixvim, ... }:

{
  imports = [
    ../../home/wm/hyprland
    ../../home/programs/eww
    ../../home/programs/kitty.nix
    # ../../home/programs/nvim.nix

    ../../modules/programs/typora/home.nix
    ../../home/programs/git.nix
    ../../home/programs/helix.nix
    ../../home/programs/waybar
  ];

  home = {
    username = "${user}";
    homeDirectory = "/home/${user}";
    stateVersion = "24.11";
  };

  programs = {
    direnv = {
      enable = true;
      enableBashIntegration = true; # see note on other shells below
      nix-direnv.enable = true;
    };

    bash.enable = true; # see note on other shells below
  };

  programs.home-manager.enable = true;
  manual.manpages.enable = false;
}
